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
    @event.build_default_event_addons
  end

  def edit
    params_symbolized_hash[:event]&.each_pair do |key, value|
      @event.send("#{key}=", value) if @event.respond_to?("#{key}=")
    end

    # build default event addons if event does not have persisted addons
    @event.create_default_event_addons

    render
  end

  def create
    create_params = params_symbolized_hash[:event].dup.with_indifferent_access
    Rails.logger.info("event_create: create_params: #{create_params}")
    TimeHelper.normalize_time_attributes(create_params)

    @event = Event.new(create_params)
    if create_params[:event_addons_attributes].present?
      @event.build_event_addons_from_params(create_params[:event_addons_attributes])
    end

    Rails.logger.info("event_create: created event: #{@event.id} event_addons: #{@event.event_addons.inspect}")

    if @event.save
      redirect_to @event
    else
      flash.now[:error] = "There was a problem creating the event: #{@event.errors.full_messages.sort.uniq.join('. ')}"
      render_flash flash
    end
  end

  def update
    update_params = params_symbolized_hash[:event].dup
    TimeHelper.normalize_time_attributes(update_params)

    Rails.logger.info("event_update: #{update_params}")

    if @event.update(update_params)
      redirect_to @event, notice: 'The event has been updated.'
    else
      flash.now[:error] = "There was a problem updating the event: #{@event.errors.full_messages}"
      render_flash(flash)
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
    @ticket_requests = @event.admissible_requests
  end

  def download_guest_list
    send_file(FnF::Services::GuestListCSV.new(@event).csv,
              filename: "#{@event.name} Guest List.csv".gsub(/\s+/, '-'),
              type: 'text/csv')
  end

  private

  def params_symbolized_hash
    @params_symbolized_hash ||= permitted_params.to_h.tap(&:symbolize_keys!)
  end

  def set_event
    @event = Event.where(id: permitted_params[:id].to_i).first
    return if @event.event_addons.present?

    @event.create_default_event_addons
    Rails.logger.info("event_set: event: #{@event.id} addons.size: #{@event.event_addons.size} event_addons: #{@event.event_addons.inspect}")
  end

  def permitted_params
    params.permit(:id,
                  :user_email,
                  :user_id,
                  :_method,
                  :authenticity_token,
                  :commit,
                  event: [
                    :name,
                    :start_time,
                    :end_time,
                    :ticket_sales_start_time,
                    :ticket_sales_end_time,
                    :ticket_requests_end_time,
                    :adult_ticket_price,
                    :kid_ticket_price,
                    :max_adult_tickets_per_request,
                    :max_kid_tickets_per_request,
                    :allow_donations,
                    :allow_financial_assistance,
                    :require_mailing_address,
                    :require_role,
                    :tickets_require_approval,
                    { event_addons_attributes: [:id, :addon_id, :price] }
                  ]
    )
          .to_hash
          .with_indifferent_access
  end
end
