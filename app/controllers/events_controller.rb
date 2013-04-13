class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_site_admin

  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
  end

  def create
    params[:event][:start_time] = Time.from_picker(params.delete(:start_time))
    params[:event][:end_time] = Time.from_picker(params.delete(:end_time))

    @event = Event.new(params[:event])

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @event = Event.find(params[:id])

    params[:event][:start_time] = Time.from_picker(params.delete(:start_time))
    params[:event][:end_time] = Time.from_picker(params.delete(:end_time))

    if @event.update_attributes(params[:event])
      redirect_to @event
    else
      render action: 'edit'
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to events_url
  end
end
