# frozen_string_literal: true

require 'tempfile'
require 'csv'

# Manage all pages related to ticket requests.
# rubocop: disable Metrics/ClassLength
class TicketRequestsController < ApplicationController
  before_action :authenticate_user!, except: %i[new create]

  before_action :set_event

  before_action :require_event_admin, except: %i[new create show edit update]
  before_action :set_ticket_request, except: %i[new create index download]

  def index
    @ticket_requests = TicketRequest
                       .includes({ event: [:price_rules] }, :payment, :user)
                       .where(event_id: @event)
                       .order('created_at DESC')
                       .to_a

    @stats = %i[pending awaiting_payment completed].each_with_object({}) do |status, stats|
      requests = @ticket_requests.select { |tr| tr.send("#{status}?") }

      stats[status] = {
        requests: requests.count,
        adults: requests.sum(&:adults),
        kids: requests.sum(&:kids),
        cabins: requests.sum(&:cabins),
        raised: requests.sum(&:price)
      }
    end

    @stats[:total] ||= Hash.new { |h, k| h[k] = 0 }
    %i[requests adults kids cabins raised].each do |measure|
      %i[pending awaiting_payment completed].each do |status|
        @stats[:total][measure] += @stats[status][measure]
      end
    end
  end

  def download
    temp_csv = Tempfile.new('csv')

    raise ArgumentError('Tempfile is nil') if temp_csv.nil? || temp_csv.path.nil?

    CSV.open(temp_csv.path, 'wb') do |csv|
      csv << (%w[name email] + TicketRequest.columns.map(&:name))
      TicketRequest.where(event_id: @event).find_each do |ticket_request|
        csv << ([ticket_request.user.name, ticket_request.user.email] +
          ticket_request.attributes.values)
      end
    end

    temp_csv.close
    send_file(temp_csv.path,
              filename: "#{@event.name} Ticket Requests.csv",
              type: 'text/csv')
  end

  def show
    return redirect_to root_path unless @ticket_request.can_view?(current_user)

    @payment = @ticket_request.payment
  end

  def new
    if signed_in?
      existing_request = TicketRequest.where(user_id: current_user, event_id: @event).order(:created_at).first

      return redirect_to event_ticket_request_path(@event, existing_request) if existing_request
    end

    @user           = current_user if signed_in?
    @ticket_request = TicketRequest.new

    if @user
      last_ticket_request = TicketRequest.where(user_id: @user&.id).order(:created_at).last
      if last_ticket_request
        %w[address_line1 address_line2 city state zip_code country_code].each do |field|
          @ticket_request.send(:"#{field}=", last_ticket_request.send(field))
        end
      end
    end
  end

  def edit
    unless @event.admin?(current_user) || current_user == @ticket_request.user
      redirect_to new_event_ticket_request_path(@event)
      return
    end

    @user = @ticket_request.user
  end

  def create
    unless @event.ticket_sales_open?
      flash.now[:error] = 'Sorry, but ticket sales have closed'
      return render action: 'new'
    end

    tr_params = permitted_params[:ticket_request].to_h || {}

    ticket_request_user = if signed_in? && current_user.present?
                            current_user
                          else
                            User.build(email: permitted_params[:email],
                                       name: permitted_params[:name],
                                       password: permitted_params[:password],
                                       password_confirmation: permitted_params[:password]).tap do |user|
                              if user.valid?
                                user.save! && sign_in(user)
                              else
                                flash.now[:error] = user.errors.full_messages.join('. ')
                                @ticket_request   = TicketRequest.new(tr_params, user:, event: @event)
                                return render action: 'new'
                              end
                            end
                          end

    if tr_params.empty?
      flash.now[:error] = 'Please fill out the form below to request tickets.'
      redirect_to new_event_ticket_request_path(@event)
    end

    tr_params[:user_id] = ticket_request_user.id

    @ticket_request = TicketRequest.new(tr_params, user_id: ticket_request_user.id, event_id: @event.id)

    Rails.logger.info("Newly created request: #{@ticket_request.inspect}")

    begin
      @ticket_request.save!
      Rails.logger.info("Saved Ticket Request, ID = #{@ticket_request.id}")

      FnF::Events::TicketRequestEvent.new(
        user: ticket_request_user,
        target: @ticket_request
      ).fire!

      if @event.tickets_require_approval || @ticket_request.free?
        redirect_to event_ticket_request_path(@event, @ticket_request)
      else
        redirect_to new_payment_url(ticket_request_id: @ticket_request)
      end
    rescue StandardError => e
      Rails.logger.error("Error saving request: #{e.message}\n\n#{@ticket_request.errors.full_messages.join(', ')}")
      flash.now[:error] = "Error saving request: #{e.message}<br ><ul>#{@ticket_request.errors.full_messages.join("\n<li>")}"
      render_flash
    end
  end

  def update
    # Allow ticket request to edit guests and nothing else
    permitted_params[:ticket_request].slice!(:guests) unless @event.admin?(current_user)

    if @ticket_request.update(permitted_params[:ticket_request])
      redirect_to event_ticket_request_path(@event, @ticket_request)
    else
      render action: 'edit'
    end
  end

  def approve
    if @ticket_request.approve
      ::FnF::Events::TicketRequestApprovedEvent.new(
        user: current_user,
        target: @ticket_request
      ).fire!
      flash[:notice] = "#{@ticket_request.user.name}'s request was approved"
    else
      flash[:error] = "Unable to approve #{@ticket_request.user.name}'s request"
    end

    redirect_to event_ticket_requests_path(@event)
  end

  def decline
    if @ticket_request.update(status: TicketRequest::STATUS_DECLINED)
      ::FnF::Events::TicketRequestDeclinedEvent.new(
        user: current_user,
        target: @ticket_request
      ).fire!
      flash[:notice] = "#{@ticket_request.user.name}'s request was declined"
    else
      flash[:error] = "Unable to decline #{@ticket_request.user.name}'s request"
    end

    redirect_to event_ticket_requests_path(@event)
  end

  def resend_approval
    TicketRequestMailer.request_approved(@ticket_request).deliver_now if @ticket_request.awaiting_payment?

    redirect_to event_ticket_requests_path(@event)
  end

  def revert_to_pending
    @ticket_request.update_attribute(:status, TicketRequest::STATUS_PENDING) if @ticket_request.declined?

    redirect_to event_ticket_requests_path(@event)
  end

  def refund
    if @ticket_request.refund
      redirect_to event_ticket_request_path(@event, @ticket_request),
                  notice: 'Ticket request was refunded'
    else
      redirect_to event_ticket_request_path(@event, @ticket_request),
                  alert: @ticket_request.errors.full_messages.join('. ')
    end
  end

  private

  def set_event
    @event = Event.find(permitted_params[:event_id])
  end

  def set_ticket_request
    @ticket_request = TicketRequest.find(permitted_params[:id])
    redirect_to @event unless @ticket_request.event == @event
  end

  def permitted_params
    params.permit(:event_id, :id, :email, :name, :password, :authenticity_token, :commit,
                  ticket_request: %i[user_id adults kids cabins needs_assistance
                                     notes special_price event_id
                                     user donation role role_explanation
                                     car_camping car_camping_explanation previous_contribution
                                     address_line1 address_line2 city state zip_code
                                     country_code admin_notes agrees_to_terms
                                     early_arrival_passes late_departure_passes guests])
  end
end

# rubocop: enable Metrics/ClassLength
