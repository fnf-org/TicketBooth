class PaymentsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @payment = Payment.find(params[:id])
    @ticket_request = @payment.ticket_request
    @event = @ticket_request.event
    return redirect_to root_path unless @payment.can_view?(current_user)
  end

  def new
    @ticket_request = TicketRequest.find(params[:ticket_request_id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)
    return redirect_to payment_path(@ticket_request.payment) if @ticket_request.payment
    @user = @ticket_request.user
    @payment = Payment.new(ticket_request: @ticket_request)
  end

  def create
    @payment = Payment.new(params[:payment])
    return redirect_to root_path unless @payment.can_view?(current_user)

    if @payment.save_and_charge
      PaymentMailer.payment_received(@payment).deliver
      redirect_to @payment, notice: 'Payment was successfully received.'
    else
      @ticket_request = @payment.ticket_request
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
                           status: Payment::STATUS_IN_PROGRESS)
    if @payment.save
      flash[:notice] = "We've recorded that your payment is en route"
      redirect_to payment_path(@payment)
    else
      flash[:error] = 'There was a problem recording your intent to pay'
      redirect_to :back
    end
  end
end
