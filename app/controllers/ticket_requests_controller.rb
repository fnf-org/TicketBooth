# frozen_string_literal: true

require 'tempfile'
require 'csv'

# Manage all pages related to ticket requests.
class TicketRequestsController < ApplicationController
  before_action :authenticate_user!, except: %i[create new]
  before_action :set_event
  before_action :set_ticket_request, except: %i[create index download]
  before_action :require_event_admin, except: %i[create new show edit update destroy]

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
        event_addons:   requests.sum(&:active_ticket_request_event_addons_count),
        raised:   requests.sum(&:price)
      }
    end

    @stats[:total] ||= Hash.new { |h, k| h[k] = 0 }
    %i[requests adults kids event_addons raised].each do |measure|
      %i[pending awaiting_payment completed].each do |status|
        @stats[:total][measure] += @stats[status][measure]
      end
    end
  end

  def download
    download_type = permitted_params[:type] || :active

    csv_file = Tempfile.new('csv')

    CSV.open(csv_file.path, 'w',
             write_headers: true,
             headers: TicketRequest.csv_header) do |csv|
      TicketRequest.for_csv(@event, type: download_type).each do |row|
        csv << row
      end
    end

    send_file(csv_file.path,
              filename: "#{@event.to_param}-ticket-requests.csv",
              type:     'text/csv')
  rescue StandardError => e
    flash.now[:error] = "Error creating CSV file: #{e.message}"
    render_flash(flash)
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
      return redirect_to root_path
    end

    # load event addons
    if signed_in?
      @user = current_user

      existing_request = TicketRequest.where(user_id: @user.id, event_id: @event).order(:created_at).first
      if existing_request
        redirect_to event_ticket_request_path(event_id: @event.id, id: existing_request.id)
      end
    end

    # build addons
    @ticket_request.build_ticket_request_event_addons
    @ticket_request
  end

  def edit
    unless @event.admin?(current_user) || current_user == @ticket_request.user
      redirect_to new_event_ticket_request_path(@event)
      return
    end

    @user = @ticket_request.user
  end

  def create
    unless signed_in?
      Rails.logger.error('#create: not signed in!'.colorize(:yellow))
      return redirect_to attend_event_path(@event)
    end

    unless @event.ticket_sales_open?
      return redirect_to attend_event_path(@event), error: @event.errors.messages.values.join('. ')
    end

    tr_params = permitted_params[:ticket_request].to_h || {}
    if tr_params.empty?
      flash.now[:error] = 'Please fill out the form below to request tickets.'
      return render_flash(flash)
    end

    Rails.logger.debug { "ticket request create: tr_params: #{tr_params}" }

    ticket_request_user = current_user
    tr_params[:user_id] = ticket_request_user.id

    @ticket_request = TicketRequest.new(tr_params,
                                        user_id: ticket_request_user.id,
                                        event_id: @event.id,
                                        guest_list: ["#{ticket_request_user.name} <#{ticket_request_user.email}>"])

    Rails.logger.info("Newly created request: #{@ticket_request.inspect}")

    begin
      @ticket_request.save!
      Rails.logger.info("Saved Ticket Request, ID = #{@ticket_request.id}")

      FnF::Events::TicketRequestEvent.new(
        user:   ticket_request_user,
        target: @ticket_request
      ).fire!

      if @event.tickets_require_approval && @ticket_request.total_tickets > 1
        Rails.logger.debug { "tr approval: #{@ticket_request.inspect}" }
        redirect_to event_ticket_request_path(@event, @ticket_request),
                    notice: 'When you know your guest names, please return here and add them below.'
      elsif !@ticket_request.all_guests_specified? && @ticket_request.total_tickets > 1
        Rails.logger.debug { "tr NOT all guests specified: #{@ticket_request.inspect}" }
        # XXX there is a bug here that flashes this when only 1 ticket being purchased.
        redirect_to edit_event_ticket_request_path(@event, @ticket_request),
                    notice: 'Please enter the guest names before you are able to pay for the ticket.'
      elsif !@event.tickets_require_approval || @ticket_request.approved?
        Rails.logger.debug { "tr please pay: #{@ticket_request.inspect}" }
        redirect_to event_ticket_request_payments_path(@event, @ticket_request),
                    notice: 'Please pay for your ticket(s).'
      end
    rescue StandardError => e
      Rails.logger.error("Error Processing Ticket Send Request: #{e.message}\n\n#{@ticket_request.errors.full_messages.join(', ')}")
      @ticket_request.destroy if @ticket_request.persisted?
      flash.now[:error] =
        "Error Processing Ticket Request — #{e.message}. Please contact the Event Admins and let them know — #{@event.admin_contacts.join(', ')}."
      render_flash(flash)
    end
  end

  def update
    # Allow ticket request to edit guests and nothing else
    ticket_request_params = permitted_params[:ticket_request]

    guests = (Array(ticket_request_params[:guest_list]) || [])
             .flatten.map(&:presence)
             .compact

    ticket_request_params.delete(:guest_list)
    ticket_request_params[:guests] = guests

    if @ticket_request.valid? && @ticket_request.update!(ticket_request_params)
      redirect_to event_ticket_request_path(@event, @ticket_request), notice: 'Ticket Request has been updated.'
    else
      render action: 'edit', error: @ticket_request.errors.full_messages.join('; ')
    end
  end

  def destroy
    Rails.logger.error("destroy# params: #{permitted_params}".colorize(:yellow))

    unless @event.admin?(current_user) || current_user == @ticket_request.user
      Rails.logger.error("ATTEMPT TO DELETE TICKET REQUEST #{@ticket_request} by #{current_user}".colorize(:red))
      flash.now[:error] = 'You do not have sufficient privileges to delete this request.'
      return render_flash(flash)
    end

    if @ticket_request.payment_received?
      flash.now[:error] = 'Can not delete request when payment has been received. It must be refunded instead.'
      return render_flash(flash)
    end

    @ticket_request.destroy! if @ticket_request&.persisted?

    redirect_to new_event_ticket_request_path(@event), notice: 'Ticket Request was successfully cancelled.'
  end

  def approve
    if @ticket_request.approve
      ::FnF::Events::TicketRequestApprovedEvent.new(
        user:   current_user,
        target: @ticket_request
      ).fire!
      redirect_to event_ticket_requests_path(@event),
                  notice: "#{@ticket_request.user.name}'s request was approved"
    else
      redirect_to event_ticket_requests_path(@event),
                  error: "Unable to approve #{@ticket_request.user.name}'s request"
    end
  end

  def decline
    if @ticket_request.update(status: TicketRequest::STATUS_DECLINED)
      ::FnF::Events::TicketRequestDeclinedEvent.new(
        user:   current_user,
        target: @ticket_request
      ).fire!
      redirect_to event_ticket_requests_path(@event),
                  error: "#{@ticket_request.user.name}'s request was declined"
    else
      redirect_to event_ticket_requests_path(@event),
                  error: "Error attempting to decline #{@ticket_request.user.name}'s request: #{@ticket_request.errors.full_messages.join('; ')}"
    end

    # render_flash(flash) && redirect_to(event_ticket_requests_path(@event))
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
                  notice: 'Ticket payment was refunded'
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
      :type,
      :_method,
      ticket_request: [
        :user_id,
        :adults,
        :kids,
        :needs_assistance,
        :notes,
        :special_price,
        :event_id,
        :user,
        :donation,
        :role,
        :role_explanation,
        :previous_contribution,
        :address_line1,
        :address_line2,
        :city,
        :state,
        :zip_code,
        :country_code,
        :admin_notes,
        :agrees_to_terms,
        { guest_list: [] },
        { ticket_request_event_addons_attributes: %i[id ticket_request_id event_addon_id quantity] }
      ]
    )
          .to_hash
          .with_indifferent_access
  end
end
