class PaymentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @payments = Payment.all
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def new
    @ticket_request = TicketRequest.find(params[:ticket_request_id])
    @user = @ticket_request.user
    @payment = Payment.new(ticket_request: @ticket_request)
    return redirect_to root_path unless @payment.can_view?(current_user)
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def create
    @payment = Payment.new(params[:payment])

    if @payment.save_and_charge
      PaymentMailer.payment_received(@payment).deliver
      redirect_to @payment, notice: 'Payment was successfully received.'
    else
      render action: 'new'
    end
  end

  def update
    @payment = Payment.find(params[:id])

    if @payment.update_attributes(params[:payment])
      redirect_to @payment, notice: 'Payment was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def other
    @ticket_request = TicketRequest.find(params[:ticket_request_id])
    @user = @ticket_request.user
  end
end
