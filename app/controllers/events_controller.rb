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
    @event = Event.new
  end

  def edit
    render
  end

  def create
    populate_permitted_params_event(permitted_params)

    @event = Event.new(permitted_params[:event])

    if @event.save
      redirect_to @event
    else
      render action: 'new'
    end
  end

  def update
    populate_permitted_params_event(permitted_params)

    if @event.update(permitted_params[:event])
      redirect_to @event
    else
      render action: 'edit'
    end
  end

  def destroy
    @event.destroy

    redirect_to events_url
  end

  def add_admin
    return redirect_to :back unless @event.admin?(current_user)

    email = permitted_params[:user_email]
    user = User.find_by(email:)
    return redirect_to :back, notice: "No user with email '#{email}' exists" unless user

    @event.admins << user

    if @event.save
      redirect_to @event
    else
      redirect_to :back,
                  error: "There was a problem adding #{email} as an admin"
    end
  end

  def remove_admin
    return redirect_to :back unless @event.admin?(current_user)

    user_id = permitted_params[:user_id]
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

  def populate_permitted_params_event(permitted_params)
    permitted_params[:event][:start_time]               = Time.from_picker(permitted_params.delete(:start_time))
    permitted_params[:event][:end_time]                 = Time.from_picker(permitted_params.delete(:end_time))
    permitted_params[:event][:ticket_sales_start_time]  = Time.from_picker(permitted_params.delete(:ticket_sales_start_time))
    permitted_params[:event][:ticket_sales_end_time]    = Time.from_picker(permitted_params.delete(:ticket_sales_end_time))
    permitted_params[:event][:ticket_requests_end_time] = Time.from_picker(permitted_params.delete(:ticket_requests_end_time))
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
    params.permit(:id, :event, :user_email, :user_id, :start_time, :end_time, :ticket_sales_start_time, :ticket_sales_end_time, :ticket_requests_end_time)
  end
end
