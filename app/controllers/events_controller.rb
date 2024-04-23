# frozen_string_literal: true

require 'tempfile'
require 'csv'

class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :require_site_admin, only: [:create]
  before_action :set_event, :require_event_admin, except: %i[index new create]

  def index
    if current_user.site_admin?
      @events = Event.order(start_time: :desc)
    elsif current_user.event_admin?
      @events = current_user.events_administrated.order(:start_time)
    else
      redirect_to :root
    end
  end

  def show
    render
  end

  def new
    @event = Event.new(Event::DEFAULT_ATTRIBUTES)
  end

  def edit
    params_symbolized_hash[:event]&.each_pair do |key, value|
      @event.send("#{key}=", value) if @event.respond_to?("#{key}=")
    end
    render
  end

  def create
    create_params = params_symbolized_hash[:event].dup
    TimeHelper.normalize_time_attributes(create_params)

    @event = Event.new(create_params)

    if @event.save
      redirect_to @event
    else
      Rails.logger.error("Can't create event: #{@event.errors.full_messages}")
      flash.now[:error] = "There was a problem creating the event: #{@event.errors.full_messages.sort.uniq.join('. ')}"
      render_flash flash
    end
  end

  def update
    update_params = params_symbolized_hash[:event].dup
    TimeHelper.normalize_time_attributes(update_params)

    if @event.update(update_params)
      redirect_to @event, notice: 'The event has been updated.'
    else
      Rails.logger.error "UPDATE ERROR: There was a problem updating the event: #{@event.errors.full_messages}"
      flash.now[:error] = "There was a problem updating the event: #{@event.errors.full_messages}"
      render_flash
    end
  end

  def destroy
    @event.destroy

    redirect_to events_url
  end

  def add_admin
    return redirect_to :back unless @event.admin?(current_user)

    email = permitted_params[:user_email]
    user  = User.find_by(email:)
    unless user
      flash.now[:error] = "No user with email '#{email}' exists"
      return render_flash(flash)
    end

    @event.admins << user

    if @event.save
      redirect_to @event
    else
      flash.now[:error] = "There was a problem adding #{email} as an admin"
      render_flash(flash)
    end
  end

  def remove_admin
    return redirect_to :back unless @event.admin?(current_user)

    user_id     = permitted_params[:user_id]
    event_admin = EventAdmin.where(event_id: @event, user_id:).first
    return redirect_to :back, notice: "No user with id #{user_id} exists" unless event_admin

    event_admin.destroy

    redirect_to @event,
                notice: "#{event_admin.user.name} is no longer an admin of #{@event.name}"
  end

  def guest_list
    @ticket_requests = completed_ticket_requests
  end

  def download_guest_list
    temp_csv = Tempfile.new('csv')

    CSV.open(temp_csv.path, 'wb') do |csv|
      csv << %w[name Guest-1 Guest-2 Guest-3 Guest-4 Guest-5]

      completed_ticket_requests.each do |ticket_request|
        csv << [ticket_request.user.name, ticket_request.guests].flatten
      end
    end

    temp_csv.close
    send_file(temp_csv.path,
              filename: "#{@event.name} Guest List.csv",
              type: 'text/csv')
  end

  private

  def params_symbolized_hash
    @params_symbolized_hash ||= permitted_params.to_h.tap(&:symbolize_keys!)
  end

  def completed_ticket_requests
    TicketRequest
      .includes(:payment, :user)
      .where(event_id: @event)
      .order('created_at DESC')
      .completed
      .sort_by { |ticket_request| ticket_request.user.name.upcase }
  end

  def set_event
    @event = Event.find(permitted_params[:id])
  end

  def permitted_params
    params.permit(
      :id,
      :user_email,
      :user_id,
      :_method,
      :authenticity_token,
      :commit,
      event: %i[
        start_time
        end_time
        ticket_sales_start_time
        ticket_sales_end_time
        ticket_requests_end_time
        adult_ticket_price
        allow_donations
        allow_financial_assistance
        cabin_price
        early_arrival_price
        end_time
        kid_ticket_price
        late_departure_price
        max_adult_tickets_per_request
        max_cabin_requests
        max_cabins_per_request
        max_kid_tickets_per_request
        name
        require_mailing_address
        start_time
        tickets_require_approval
      ]
    )
          .to_hash
          .with_indifferent_access
  end
end
