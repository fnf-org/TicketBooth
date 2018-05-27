class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @payment = Payment.find(params[:id])
    @charge = Stripe::Charge.retrieve(@payment.stripe_charge_id) if @payment.stripe_charge_id
    @ticket_request = @payment.ticket_request
    @event = @ticket_request.event
    return redirect_to root_path unless @payment.can_view?(current_user)
  end

  def new
    @ticket_request = TicketRequest.find(params[:ticket_request_id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)
    return redirect_to payment_path(@ticket_request.payment) if @ticket_request.payment
    @event = @ticket_request.event

    unless @ticket_request.all_guests_specified?
      return redirect_to edit_event_ticket_request_path(@event, @ticket_request),
             alert: 'You must fill out all your guests before you can purchase a ticket'
    end

    unless @event.ticket_sales_open?
      return redirect_to event_ticket_request_path(@event, @ticket_request),
             alert: "Sorry, ticket sales for #{@event.name} have closed."
    end

    @user = @ticket_request.user
    @payment = Payment.new.tap { |p| p.ticket_request = @ticket_request }
  end

  def create
    @payment = Payment.new(params[:payment])
    return redirect_to root_path unless @payment.can_view?(current_user)

    if @payment.save_and_charge!
      PaymentMailer.payment_received(@payment).deliver_now
      @payment.ticket_request.mark_complete
      redirect_to @payment, notice: 'Payment was successfully received.'
    else
      @ticket_request = @payment.ticket_request
      @event = @ticket_request.event
      @user = @ticket_request.user
      render action: 'new'
    end
  end

  def other
    @ticket_request = TicketRequest.find(params[:ticket_request_id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)
    return redirect_to payment_path(@ticket_request.payment) if @ticket_request.payment
    @user = @ticket_request.user
  end

  def sent
    @ticket_request = TicketRequest.find(params[:ticket_request_id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)

    @payment = Payment.new(ticket_request_id: @ticket_request.id,
                           explanation: params[:explanation],
                           status: Payment::STATUS_IN_PROGRESS)
    if @payment.save
      flash[:notice] = "We've recorded that your payment is en route"
      redirect_to payment_path(@payment)
    else
      flash[:error] = 'There was a problem recording your intent to pay'
      redirect_to :back
    end
  end

  def mark_received
    @ticket_request = TicketRequest.find(params[:ticket_request_id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)

    @payment = Payment.where(ticket_request_id: @ticket_request.id,
                             status: Payment::STATUS_IN_PROGRESS)
                      .first

    if @payment
      @payment.mark_received
      @payment.ticket_request.mark_complete
      PaymentMailer.payment_received(@payment).deliver_now
      redirect_to :back
    end
  end
end
