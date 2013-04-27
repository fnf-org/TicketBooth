class TimeSlotsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_event
  before_filter :require_event_admin
  before_filter :set_job
  before_filter :set_time_slot, only: [:edit, :update, :destroy]

  def new
    @time_slot = TimeSlot.new
  end

  def edit
    render
  end

  def create
    params[:time_slot][:start_time] = Time.from_picker(params.delete(:start_time))
    params[:time_slot][:end_time] = Time.from_picker(params.delete(:end_time))

    @time_slot = TimeSlot.new(params[:time_slot])

    if @time_slot.save
      redirect_to event_job_path(@event, @job)
    else
      render action: 'new'
    end
  end

  def update
    params[:time_slot][:start_time] = Time.from_picker(params.delete(:start_time))
    params[:time_slot][:end_time] = Time.from_picker(params.delete(:end_time))

    if @time_slot.update_attributes(params[:time_slot])
      redirect_to event_job_path(@event, @job),
        notice: 'Time slot was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
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

  def set_time_slot
    @time_slot = TimeSlot.find(params[:id])
  end
end
