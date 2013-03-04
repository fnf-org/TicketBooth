class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_site_admin, except: :show

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
    # TODO: Figure out ideal way to manage datetimes
    start_time = Time.now + 100.days
    end_time = start_time + 4.days
    params[:event][:start_time] = start_time
    params[:event][:end_time] = end_time
    @event = Event.new(params[:event])

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @event = Event.find(params[:id])

    if @job.update_attributes(params[:job])
      redirect_to @job, notice: 'Event was successfully updated.'
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
