class ShiftsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_event

  def index
    @jobs = Job.where(event_id: @event.id).
      includes(:time_slots => :shifts).
      select { |job| job.time_slots.any? }
  end

  def create
    @shift = Shift.new(params[:shift])

    if @shift.save
      redirect_to event_shifts_path(@event),
        notice: "Successfully volunteered for #{@shift.time_slot.job.name}" +
                " for #{@shift.time_slot.start_time.to_s(:time)}"
    else
      render action: 'index'
    end
  end

  def destroy
    @shift = Shift.includes(:time_slot => :job).find(params[:id])
    @shift.destroy

    redirect_to event_shifts_url(@event),
      notice: "Unvolunteered from #{@shift.time_slot.job.name}" +
              " for #{@shift.time_slot.start_time.to_s(:time)}"
  end

private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
