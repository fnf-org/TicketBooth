class TicketRequestsController < ApplicationController
  before_filter :authenticate_user!, except: %i[new create]
  before_filter :set_event
  before_filter :require_event_admin,
                only: %i[index edit update approve decline refund]
  before_filter :set_ticket_request, only: %i[show edit update approve decline refund]

  def index
    @ticket_requests = TicketRequest
      .includes({ event: [:price_rules] }, :payment, :user)
      .where(event_id: @event)
      .order('created_at DESC')
      .to_a

    @stats = %i[pending awaiting_payment completed].reduce({}) do |stats, status|
      requests = @ticket_requests.select { |tr| tr.send(status.to_s + '?') }

      stats[status] = {
        requests: requests.count,
        adults:   requests.sum(&:adults),
        kids:     requests.sum(&:kids),
        cabins:   requests.sum(&:cabins),
        raised:   requests.sum(&:price),
      }

      stats
    end

    @stats[:total] ||= Hash.new { |h, k| h[k] = 0 }
    %i[requests adults kids cabins raised].each do |measure|
      %i[pending awaiting_payment completed].each do |status|
        @stats[:total][measure] += @stats[status][measure]
      end
    end
  end

  def show
    return redirect_to root_path unless @ticket_request.can_view?(current_user)
    @payment = @ticket_request.payment
  end

  def new
    if signed_in?
      existing_request = TicketRequest.where(user_id: current_user, event_id: @event).first

      if existing_request
        return redirect_to event_ticket_request_path(@event, existing_request)
      end
    end

    @user = current_user if signed_in?
    @ticket_request = TicketRequest.new
  end

  def edit
    @user = @ticket_request.user
  end

  def create
    unless @event.ticket_sales_open?
      flash[:error] = 'Sorry, but ticket sales have closed'
      return render action: 'new'
    end

    params[:ticket_request][:user] = current_user if signed_in?
    @ticket_request = TicketRequest.new(params[:ticket_request])

    if @ticket_request.save
      sign_in(@ticket_request.user) unless signed_in?

      if @event.tickets_require_approval || @ticket_request.free?
        redirect_to event_ticket_request_path(@event, @ticket_request)
      else
        redirect_to new_payment_url(ticket_request_id: @ticket_request)
      end

      TicketRequestMailer.request_received(@ticket_request).deliver
    else
      render action: 'new'
    end
  end

  def update
    if @ticket_request.update_attributes(params[:ticket_request])
      redirect_to event_ticket_request_path(@event, @ticket_request)
    else
      render action: 'edit'
    end
  end

  def approve
    if @ticket_request.approve
      TicketRequestMailer.request_approved(@ticket_request).deliver
      flash[:notice] = "#{@ticket_request.user.name}'s request was approved"
    else
      flash[:error] = "Unable to approve #{@ticket_request.user.name}'s request"
    end

    redirect_to event_ticket_requests_path(@event)
  end

  def decline
    if @ticket_request.update_attributes(status: TicketRequest::STATUS_DECLINED)
      flash[:notice] = "#{@ticket_request.user.name}'s request was declined"
    else
      flash[:error] = "Unable to decline #{@ticket_request.user.name}'s request"
    end

    redirect_to event_ticket_requests_path(@event)
  end

  def refund
    if @ticket_request.refund
      return redirect_to event_ticket_request_path(@event, @ticket_request),
             notice: 'Ticket request was refunded'
    else
      return redirect_to event_ticket_request_path(@event, @ticket_request),
             alert: @ticket_request.errors.full_messages.join('. ')
    end
  end

private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_ticket_request
    @ticket_request = TicketRequest.find(params[:id])
    redirect_to @event unless @ticket_request.event == @event
  end
end
