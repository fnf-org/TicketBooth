# frozen_string_literal: true

class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :require_event_admin

  def index
    @jobs = Job.where(event_id: @event).order(:id)
  end

  def show
    @job = Job.find(params[:id])
    @time_slots = @job.time_slots.sort_by(&:end_time)
  end

  def new
    @job = Job.new
  end

  def edit
    @job = Job.find(params[:id])
  end

  def create
    params[:job][:event_id] = @event.id
    @job = Job.new(params[:job])

    if @job.save
      create_time_slots
      redirect_to event_job_path(@event, @job)
    else
      render action: 'new'
    end
  end

  def update
    @job = Job.find(params[:id])

    if @job.update_attributes(params[:job])
      redirect_to event_job_path(@event, @job),
                  notice: 'Job was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    redirect_to event_jobs_url(@event)
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  # TODO: This method suggests that the current way we represent shifts needs to
  # change so we don't have to create a ridiculous number of records in our
  # database. That work can safely be put-off for now though, as no one but
  # CloudWatch is using this system.
  def create_time_slots
    return unless params[:start_time]

    start_time = Time.from_picker(params.delete(:start_time))
    end_time = Time.from_picker(params.delete(:end_time))

    return if end_time < start_time # Prevent infinite loop

    shift_length = params.delete(:shift_length).to_i
    shift_overlap = params.delete(:shift_overlap).to_i
    people_per_shift = params.delete(:people_per_shift)

    num_shifts = ((end_time - start_time) / shift_length).ceil
    return if num_shifts > 100 # Arbitrary threshold to prevent flooding database

    cur_time = start_time
    TimeSlot.transaction do
      while cur_time < end_time
        end_shift_time = cur_time + shift_length + shift_overlap
        TimeSlot.create! job: @job,
                         start_time: cur_time,
                         end_time: [end_shift_time, end_time].min,
                         slots: people_per_shift
        cur_time += shift_length
      end
    end
  end
end
