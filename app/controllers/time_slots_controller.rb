class TimeSlotsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_site_admin
  before_filter :set_event
  before_filter :set_job

  def new
    @time_slot = TimeSlot.new
  end

  def edit
    @time_slot = TimeSlot.find(params[:id])
  end

  def create
    @time_slot = TimeSlot.new(params[:time_slot])

    if @time_slot.save
      redirect_to event_job_path(@event, @job),
        notice: 'Time slot was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @time_slot = TimeSlot.find(params[:id])

    if @time_slot.update_attributes(params[:time_slot])
      redirect_to event_job_path(@event, @job),
        notice: 'Time slot was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @time_slot = TimeSlot.find(params[:id])
    @time_slot.destroy

    redirect_to event_job_path(@event, @job)
  end

private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_job
    @job = Job.find(params[:job_id])
  end
end
