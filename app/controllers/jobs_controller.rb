class JobsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_event
  before_filter :require_event_admin

  def index
    @jobs = Job.where(event_id: @event.id)
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
      redirect_to event_job_path(@event, @job),
        notice: 'Job was successfully created.'
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
end
