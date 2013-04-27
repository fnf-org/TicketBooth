class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_site_admin, only: [:create]
  before_filter :set_event, :require_event_admin, except: [:index, :new, :create]

  def index
    if current_user.site_admin?
      @events = Event.order(:start_time)
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
    params[:event][:start_time] = Time.from_picker(params.delete(:start_time))
    params[:event][:end_time] = Time.from_picker(params.delete(:end_time))

    @event = Event.new(params[:event])

    if @event.save
      redirect_to @event
    else
      render action: 'new'
    end
  end

  def update
    params[:event][:start_time] = Time.from_picker(params.delete(:start_time))
    params[:event][:end_time] = Time.from_picker(params.delete(:end_time))

    if @event.update_attributes(params[:event])
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

    email = params[:user_email]
    user = User.find_by_email(email)
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

    user_id = params[:user_id]
    event_admin = EventAdmin.where(event_id: @event, user_id: user_id).first
    return redirect_to :back, notice: "No user with id #{user_id} exists" unless event_admin
    event_admin.destroy

    redirect_to @event,
      notice: "#{event_admin.user.name} is no longer an admin of #{@event.name}"
  end

private

  def set_event
    @event = Event.find(params[:id])
  end
end
