# frozen_string_literal: true

class TimeSlotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :require_event_admin
  before_action :set_job
  before_action :set_time_slot, only: %i[edit update destroy]

  def new
    # If a previous time slot exists, pre-populate info to match that one, but
    # for the next slot
    if @job.time_slots.any?
      last_time_slot = @job.time_slots.last
      start_time = last_time_slot.end_time
      end_time = last_time_slot.end_time + (last_time_slot.end_time - last_time_slot.start_time)
      slots = last_time_slot.slots
    end

    @time_slot = TimeSlot.new start_time: start_time,
                              end_time: end_time,
                              slots: slots
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
      redirect_to event_job_path(@event, @job)
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
