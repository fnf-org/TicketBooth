# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def show
    @payment = Payment.find(permit_params[:id])
    redirect_to root_path unless @payment.present? && @payment.can_view?(current_user)

    @payment_intent = @payment.payment_intent if @payment.stripe_payment_id
    @ticket_request = @payment.ticket_request
    @event = @ticket_request.event
  end

  def new
    Rails.logger.info("New Payment ticket request id: #{permit_params[:ticket_request_id]}")

    @ticket_request = TicketRequest.find(permit_params[:ticket_request_id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)

    @event = @ticket_request.event

    unless @ticket_request.all_guests_specified?
      return redirect_to edit_event_ticket_request_path(@event, @ticket_request),
                         alert: 'You must fill out all your guests before you can purchase a ticket'
    end

    unless @event.ticket_sales_open?
      return redirect_to event_ticket_request_path(@event, @ticket_request),
                         alert: "Sorry, ticket sales for #{@event.name} have closed."
    end

    @stripe_publishable_api_key ||= stripe_publishable_api_key

    @user = @ticket_request.user
    @payment = Payment.new.tap { |p| p.ticket_request = @ticket_request }
  end

  # Creates new Payment
  # Create Payment Intent and save PaymentIntentId in Payment
  def create
    Rails.logger.info("Payment Create ticket request id: #{permit_params[:ticket_request_id]}")
    new
    create_with_payment_intent
    @payment
  end
  # create new payment and stripe payment intent using existing payment

  def create_with_payment_intent
    @payment ||= Payment.find(permit_params[:id])
    return redirect_to root_path unless @payment.present? && @payment.can_view?(current_user)

    @payment.save_with_payment_intent
  end

  def confirm
    if permit_params[:id]
      @payment = Payment.find(permit_params[:id])
    elsif permit_params[:stripe_payment_id]
      @payment = Payment.where(stripe_payment_id: permit_params[:stripe_payment_id]).first
    end

    return redirect_to root_path unless @payment.present? && @payment.can_view?(current_user)

    @payment.mark_received
    @payment.ticket_request.mark_complete
    PaymentMailer.payment_received(@payment).deliver_now

    # XXX switch to checkout page ??
    # redirect_to @payment, notice: 'Payment was successfully received.'
  end

  def other
    @ticket_request = TicketRequest.find(permit_params[:ticket_request_id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)
    return redirect_to payment_path(@ticket_request.payment) if @ticket_request.payment

    @user = @ticket_request.user
  end

  def sent
    @ticket_request = TicketRequest.find(permit_params[:ticket_request_id])
    return redirect_to root_path unless @ticket_request.can_view?(current_user)

    @payment = Payment.new(ticket_request_id: @ticket_request.id,
                           explanation: permit_params[:explanation],
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
    @ticket_request = TicketRequest.find(permit_params[:ticket_request_id])
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

  private

  def permit_params
    params.permit(
      :id,
      :ticket_request_id,
      payment: %i[
        ticket_request_id
        ticket_request_attributes
        status
        stripe_payment_id
        explanation
      ]
    )
          .to_hash
          .with_indifferent_access
  end
end
