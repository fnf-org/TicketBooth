class ShiftsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_event

  def index
    @ticket_request = @event.ticket_requests.where(user_id: current_user).first
    if !@ticket_request.present? && !current_user.site_admin?
      flash[:error] = 'The user you are logged in with has not requested a ticket for this event'
      return redirect_to :root
    end

    @jobs = Job.where(event_id: @event.id).
      order(:id).
      includes(:time_slots => [{:shifts => :user }, :job]).
      select { |job| job.time_slots.any? }
  end

  def create
    @shift = Shift.new(params[:shift])

    if @shift.save
      redirect_to event_shifts_path(@event),
        notice: "Successfully volunteered for #{@shift.time_slot.job.name}" +
                " for #{@shift.time_slot.start_time.localtime.to_s(:dhmm)}"
    else
      render action: 'index'
    end
  end

  def destroy
    @shift = Shift.includes(:time_slot => :job).find(params[:id])
    @shift.destroy

    redirect_to event_shifts_url(@event),
      notice: "Unvolunteered from #{@shift.time_slot.job.name}" +
              " for #{@shift.time_slot.start_time.localtime.to_s(:dhmm)}"
  end

private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
