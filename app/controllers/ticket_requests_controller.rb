class TicketRequestsController < ApplicationController
  force_ssl

  before_filter :authenticate_user!,
    only: [:index, :show, :edit, :update, :approve, :decline]
  before_filter :set_event
  before_filter :require_event_admin,
    only: [:index, :edit, :update, :approve, :decline]
  before_filter :set_ticket_request,
    only: [:show, :edit, :update, :approve, :decline]

  def index
    @ticket_requests = TicketRequest.
      includes({ event: [ :price_rules ] }, :payment, :user).
      where(event_id: @event).
      order('created_at DESC').
      to_a

    @stats = [:completed,
              :pending,
              :approved,
              :declined,
             ].inject({}) do |stats, status|
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
  end

  def show
    return redirect_to root_path unless @ticket_request.can_view?(current_user)
    @payment = @ticket_request.payment
  end

  def new
    if signed_in?
      existing_request = TicketRequest.where(event_id: @event, user_id: current_user).first
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

private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_ticket_request
    @ticket_request = TicketRequest.find(params[:id])
    redirect_to @event unless @ticket_request.event == @event
  end
end
