class TicketRequestsController < ApplicationController
  before_filter :authenticate_user!,
    only: [:index, :show, :edit, :update, :approve, :decline]
  before_filter :set_event
  before_filter :require_event_admin,
    only: [:index, :edit, :update, :approve, :decline]
  before_filter :set_ticket_request,
    only: [:show, :edit, :update, :approve, :decline]

  def index
    @ticket_requests = TicketRequest.
      where(event_id: @event.id).
      order('created_at DESC').
      all

    @stats = {
      potential: {
        requests: @ticket_requests.count,
        adults:   TicketRequest.sum('adults'),
        kids:     TicketRequest.sum('kids'),
        cabins:   TicketRequest.sum('cabins'),
        raised:   @ticket_requests.inject(0) { |sum, tr| sum + tr.price }
      },
      pending: {
        requests: TicketRequest.pending.count,
        adults:   TicketRequest.pending.sum('adults'),
        kids:     TicketRequest.pending.sum('kids'),
        cabins:   TicketRequest.pending.sum('cabins'),
        raised:   @ticket_requests.select { |tr| tr.pending? }.
                                 inject(0) { |sum, tr| sum + tr.price }
      },
      approved: {
        requests: TicketRequest.approved.count,
        adults:   TicketRequest.approved.sum('adults'),
        kids:     TicketRequest.approved.sum('kids'),
        cabins:   TicketRequest.approved.sum('cabins'),
        raised:   @ticket_requests.select { |tr| tr.approved? }.
                                 inject(0) { |sum, tr| sum + tr.price }
      },
      declined: {
        requests: TicketRequest.declined.count,
        adults:   TicketRequest.declined.sum('adults'),
        kids:     TicketRequest.declined.sum('kids'),
        cabins:   TicketRequest.declined.sum('cabins'),
        raised:   @ticket_requests.select { |tr| tr.declined? }.
                                 inject(0) { |sum, tr| sum + tr.price }
      }
    }
  end

  def show
    return redirect_to root_path unless @ticket_request.can_view?(current_user)
    @payment = @ticket_request.payment
  end

  def new
    if signed_in?
      existing_request = TicketRequest.where(user_id: current_user).first
      if existing_request.present?
        return redirect_to event_ticket_request_path(@event, existing_request)
      end

      # Otherwise we're creating a ticket request as the signed-in user
      @user = current_user
    end

    @ticket_request = TicketRequest.new
  end

  def edit
    @user = @ticket_request.user
  end

  def create
    @ticket_request = TicketRequest.new(params[:ticket_request])

    unless signed_in?
      # User parameters are included separately
      user = User.new(params.slice(:name, :email, :password, :password_confirmation))

      if user.save
        @ticket_request.user_id = user.id

        # Automatically sign in so that if there's something wrong with the
        # ticket request we don't need to create another user.
        sign_in(user)
      else
        # Add user errors to ticket validation since we're piggy-backing on the
        # ticket form
        user.errors.full_messages.each do |error|
          @ticket_request.errors[:base] << error
        end

        return render action: 'new'
      end
    end

    if @ticket_request.save
      redirect_to event_ticket_request_path(@event, @ticket_request)
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
    if @ticket_request.update_attributes(status: TicketRequest::STATUS_APPROVED)
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

private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_ticket_request
    @ticket_request = TicketRequest.find(params[:id])
    redirect_to @event unless @ticket_request.event == @event
  end
end
