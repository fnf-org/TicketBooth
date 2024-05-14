# frozen_string_literal: true

require 'tempfile'
require 'csv'

# Manage all pages related to ticket requests.
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
        adults:   requests.sum(&:adults),
        kids:     requests.sum(&:kids),
        cabins:   requests.sum(&:cabins),
        raised:   requests.sum(&:price)
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
      csv << (%w[name email]
      TicketRequest.where(event_id: @event).find_each do |ticket_request|
        csv << ticket_request.guests_array
      end
    end

    temp_csv.close
    send_file(temp_csv.path,
              filename: "#{@event.name} Ticket Requests.csv",
              type:     'text/csv')
  end

  def show
    return redirect_to root_path unless @ticket_request.can_view?(current_user)

    # if ticket_request is approved, but guests are not filled out
    # we could redirect to the ticket request edit path
    if !@event.admin?(current_user) && @ticket_request.approved? && !@ticket_request.all_guests_specified?
      return redirect_to "#{edit_event_ticket_request_path(@event, @ticket_request)}#guests",
                         alert: 'Please fill out your guest names and guest emails before purchasing a ticket.'
    end

    @payment = @ticket_request.payment
  end

  def new
    @ticket_request = TicketRequest.new(event_id: @event.id)

    unless @event.ticket_requests_open?
      flash.now[:error] = @event.errors.full_messages.join('. ')
      return render action: 'new'
    end

    if signed_in?
      @user = current_user

      existing_request = TicketRequest.where(user_id: @user.id, event_id: @event).order(:created_at).first
      if existing_request
        redirect_to event_ticket_request_path(event_id: @event.id, id: existing_request.id)
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

  # rubocop: disable Metrics/AbcSize
  def create
    unless @event.ticket_sales_open?
      flash.now[:error] = @event.errors.messages.values.join('. ')
      return render_flash(flash)
    end

    tr_params = permitted_params[:ticket_request].to_h || {}

    ticket_request_user = if signed_in? && current_user.present?
                            current_user
                          else
                            User.build(email:                 permitted_params[:email],
                                       name:                  permitted_params[:name],
                                       password:              permitted_params[:password],
                                       password_confirmation: permitted_params[:password]).tap do |user|
                              if user.valid?
                                user.save! && sign_in(user)
                              else
                                flash.now[:error] = user.errors.full_messages.join('. ')
                                @ticket_request   = TicketRequest.new(tr_params, user:, event: @event)
                                return render_flash(flash)
                              end
                            end
                          end

    if tr_params.empty?
      flash.now[:error] = 'Please fill out the form below to request tickets.'
      return render_flash(flash)
    end

    tr_params[:user_id] = ticket_request_user.id

    @ticket_request = TicketRequest.new(tr_params, user_id: ticket_request_user.id, event_id: @event.id)

    Rails.logger.info("Newly created request: #{@ticket_request.inspect}")

    begin
      @ticket_request.save!
      Rails.logger.info("Saved Ticket Request, ID = #{@ticket_request.id}")

      FnF::Events::TicketRequestEvent.new(
        user:   ticket_request_user,
        target: @ticket_request
      ).fire!

      if @event.tickets_require_approval || @ticket_request.free?
        redirect_to edit_event_ticket_request_path(@event, @ticket_request), notice: 'Please add everyone in your party.'
      else
        redirect_to new_payment_url(ticket_request_id: @ticket_request)
      end
    rescue StandardError => e
      Rails.logger.error("Error Processing Ticket Send Request: #{e.message}\n\n#{@ticket_request.errors.full_messages.join(', ')}")
      @ticket_request.destroy if @ticket_request.persisted?
      flash.now[:error] =
        "Error Processing Ticket Request — #{e.message}. Please contact the Event Admins and let them know — #{@event.admin_contacts.join(', ')}."
      render_flash(flash)
    end
  end

  # rubocop: enable Metrics/AbcSize

  def update
    # Allow ticket request to edit guests and nothing else
    ticket_request_params = permitted_params[:ticket_request]

    guests = (Array(ticket_request_params[:guest_list]) || [])
             .flatten.map(&:presence)
             .compact

    ticket_request_params.delete(:guest_list)
    ticket_request_params[:guests] = guests

    Rails.logger.info("guests: #{guests.inspect}")
    Rails.logger.info("params: #{permitted_params.inspect}")

    Rails.logger.info("ticket_request_params: #{ticket_request_params.inspect}")

    if !@event.admin?(current_user) && guests.size != @ticket_request.total_tickets
      flash.now[:error] = 'Please enter each guest and kid in your party. For the kids include their ages, instead of the emails.'
      return render_flash(flash)
    end

    if @ticket_request.update(ticket_request_params)
      redirect_to event_ticket_request_path(@event, @ticket_request)
    else
      render action: 'edit'
    end
  end

  def destroy
    unless @event.admin?(current_user) || current_user == @ticket_request.user
      flash.now[:error] = 'You do not have sufficient privileges to delete this request.'
      return render_flash(flash)
    end

    if @ticket_request.payment_received?
      flash.now[:error] = 'Can not delete request when payment has been received.'
      return render_flash(flash)
    end

    ticket_request_id = @ticket_request.id
    @ticket_request.destroy if @ticket_request&.persisted?

    redirect_to new_event_ticket_request_path(@event), notice: "Ticket Request ID #{ticket_request_id} was deleted."
  end

  def approve
    if @ticket_request.approve
      ::FnF::Events::TicketRequestApprovedEvent.new(
        user:   current_user,
        target: @ticket_request
      ).fire!
      flash.now[:notice] = "#{@ticket_request.user.name}'s request was approved"
    else
      flash.now[:error] = "Unable to approve #{@ticket_request.user.name}'s request"
    end

    # render_flash(flash) && redirect_to(event_ticket_requests_path(@event))
    redirect_to(event_ticket_requests_path(@event))
  end

  def decline
    if @ticket_request.update(status: TicketRequest::STATUS_DECLINED)
      ::FnF::Events::TicketRequestDeclinedEvent.new(
        user:   current_user,
        target: @ticket_request
      ).fire!
      flash[:notice] = "#{@ticket_request.user.name}'s request was declined"
    else
      flash[:error] = "Unable to decline #{@ticket_request.user.name}'s request"
    end

    # render_flash(flash) && redirect_to(event_ticket_requests_path(@event))
    redirect_to(event_ticket_requests_path(@event))
  end

  def resend_approval
    unless @ticket_request.awaiting_payment?
      flash.now[:error] = 'Ticket request does not qualify for a payment yet.'
      return render_flash(flash)
    end

    TicketRequestMailer.request_approved(@ticket_request).deliver_later
    flash.now[:notice] = 'Approval requests has been resent.'
    render_flash(flash)
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

  def ticket_request_id
    permitted_params[:id]
  end

  def permitted_params
    params.permit(
      :id,
      :event_id,
      :email,
      :name,
      :password,
      :authenticity_token,
      :commit,
      ticket_request: [
        :user_id,
        :adults,
        :kids,
        :cabins,
        :needs_assistance,
        :notes,
        :special_price,
        :event_id,
        :user,
        :donation,
        :role,
        :role_explanation,
        :car_camping,
        :car_camping_explanation,
        :previous_contribution,
        :address_line1,
        :address_line2,
        :city,
        :state,
        :zip_code,
        :country_code,
        :admin_notes,
        :agrees_to_terms,
        :early_arrival_passes,
        :late_departure_passes,
        { guest_list: [] }
      ]
    )
          .to_hash
          .with_indifferent_access
  end
end
