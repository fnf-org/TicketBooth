# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_event
  before_action :set_ticket_request
  before_action :set_payment
  before_action :validate_payment

  def show
    # Rails.logger.debug("Show Payment: payment #{@payment.id}")

    unless @payment&.can_view?(current_user)
      return redirect_to root_path, alert: 'This payment request is inaccessible to the logged in user'
    end

    unless @payment.ticket_request == @ticket_request
      return redirect_to root_path, alert: 'This payment request does not belong to this ticket_request'
    end

    @payment_intent = @payment.payment_intent if @payment.stripe_payment_id
    @ticket_request = @payment.ticket_request
    @event = @ticket_request.event
  end

  def new
    Rails.logger.info("New Payment ticket request id: #{@ticket_request.id}")
    initialize_payment
  end

  # Creates new Payment
  # Create Payment Intent and save PaymentIntentId in Payment
  def create
    if save_payment
      respond_to do |format|
        format.json do
          render json: {
            clientSecret: @payment.payment_intent_client_secret
          }
        end
      end
    else
      respond_to do |format|
        format.json do
          render json: {
            error: flash.now[:error]
          }
        end
      end
    end
  end

  # create new payment and stripe payment intent using existing payment

  def confirm
    unless @payment.in_progress?
      Rails.logger.info("Payment Confirmation not in progress: #{@payment.id} status: #{@payment.status}")
      return redirect_to root_path, alert: 'This payment request can not be confirmed'
    end

    if @payment.received?
      Rails.logger.info("Payment Confirmation already received: #{@payment.id} status: #{@payment.status}")
      return redirect_to root_path, alert: 'This payment request has already been confirmed.'
    end

    # has to have a stripe payment id and payment must not already be received
    if @payment.stripe_payment_id.blank?
      Rails.logger.error("Invalid payment confirmation id: #{@payment.id} missing stripe_payment_id")
      return redirect_to root_path, alert: 'This payment request can not be confirmed.'
    end

    @payment.mark_received
    @payment.ticket_request.mark_complete
    PaymentMailer.payment_received(@payment).deliver_now
  end

  def other
    @user = @ticket_request.user
  end

  def sent
    return redirect_to root_path unless @ticket_request.can_view?(current_user)

    @payment = Payment.new(ticket_request_id: @ticket_request.id,
                           explanation: permitted_params[:explanation],
                           status: Payment::STATUS_IN_PROGRESS)
    if @payment.save
      flash[:notice] = "We've recorded that your payment is en route"
      redirect_to payment_path(@payment)
    else
      flash[:error] = 'There was a problem recording your intent to pay'
      redirect_to :back
    end
  end

  private

  def ticket_request_id
    permitted_params[:ticket_request_id]
  end

  def set_payment
    Rails.logger.debug { "PaymentsController: set_payment params: #{params}" }
    if @ticket_request.present?
      @payment = @ticket_request.payment
    elsif permitted_params[:payment_intent] || permitted_params[:stripe_payment_id]
      strip_id = permitted_params[:payment_intent] || permitted_params[:stripe_payment_id]
      @payment = Payment.where(stripe_payment_id: strip_id).first
    elsif permitted_params[:ticket_request_id].is_a?(Numeric)
      @payment = Payment.where(ticket_request_id: permitted_params[:ticket_request_id]).first
    elsif permitted_params[:id].is_a?(Numeric)
      @payment = Payment.find(permitted_params[:id])
    else
      true
    end
  end

  def save_payment
    initialize_payment

    return redirect_to root_path unless @payment.present? && @payment.can_view?(current_user)

    @payment.save_with_payment_intent.tap do |result|
      flash.now[:error] = @payment.errors.full_messages.to_sentence unless result
    end
  end

  def initialize_payment
    @stripe_publishable_api_key ||= Rails.configuration.stripe[:publishable_api_key]

    @user = @ticket_request.user
    @payment = @ticket_request&.payment || @ticket_request&.build_payment
  end

  # @description Redirect the user if the payment can not be applied to the ticket request
  def validate_payment
    Rails.logger.debug { "PaymentsController: @ticket_request #{@ticket_request.id} current_user: #{@user&.inspect}" }

    unless @event.ticket_sales_open?
      redirect_to event_path(@event),
                  alert: "Sorry, ticket sales for #{@event.name} have closed."
    end

    unless @ticket_request.owner?(current_user)
      Rails.logger.debug { "PaymentsController: @ticket_request #{@ticket_request.id} NOT OWNER current_user: #{@user&.inspect}" }

      redirect_to root_path, alert: 'You are not authorized to make payments for this ticket request.'
    end

    unless @ticket_request.all_guests_specified?
      redirect_to edit_event_ticket_request_path(@event, @ticket_request),
                  alert: 'You must fill out all your guests before you can purchase a ticket.'
    end
  end

  def mark_received
    @ticket_request = TicketRequest.find(permitted_params[:ticket_request_id])
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

  def permitted_params
    params.permit(
      :id,
      :event_id,
      :ticket_request_id,
      :stripe_payment_id,
      :payment_intent,
      payment: %i[
        ticket_request
        ticket_request_id
        ticket_request_attributes
        status
        explanation
      ]
    )
          .to_hash
          .with_indifferent_access
  end
end
