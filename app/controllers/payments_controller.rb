# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_event
  before_action :set_ticket_request
  before_action :set_payment
  before_action :initialize_payment, except: %i[show confirm other]
  before_action :validate_payment, except: %i[confirm]

  def show
    Rails.logger.debug { "#show() => @ticket_request = #{@ticket_request&.inspect} params: #{params}" }
    self
  end

  def new
    Rails.logger.debug { "#new() => @ticket_request = #{@ticket_request&.inspect}" }
  end

  # Creates new Payment
  # Create Payment Intent and save PaymentIntentId in Payment
  def create
    Rails.logger.debug { "#create() => @ticket_request = #{@ticket_request&.inspect} params: #{params}" }

    # check to see if we have an existing stripe payment intent. retrieve or save
    @payment.retrieve_or_save_payment_intent

    if @payment.payment_in_progress?
      respond_to do |format|
        format.json do
          render json: {
            clientSecret: @payment.payment_intent_client_secret
          }
        end
      end
    else
      Rails.logger.error("Create Payment payment #{@payment.id} missing payment intent")
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
    redirect_path, options = validate_payment_confirmation
    if redirect_path
      Rails.logger.info("#confirm() => redirect_path: #{redirect_path}")
      return redirect_to redirect_path, options || {}
    else
      Rails.logger.info("#confirm() => marking payment id #{@payment.id} as received")
    end

    mark_payment_completed
  end

  # human has marked the payment as confirmed received and completed.
  # Annotate that manual was set
  def manual_confirmation
    # cancel any stripe payment intent, so there is no orphaned intent
    @payment.cancel_payment_intent

    # update payment with explanation.
    @payment.update(explanation: 'humanly marked received', provider: :other)

    # mark payment and ticket request completed
    mark_payment_completed
    Rails.logger.info("#manual_confirmation() => @payment #{@payment.inspect}")

    redirect_to event_ticket_requests_path(@event, @ticket_request)
  end

  def other
    @user = @ticket_request.user
  end

  # handle other forms of payment than credit card / stripe
  # set payment provider and cancel the Stripe PaymentIntent
  def sent
    # set explanation, provider, status.
    @payment.update(explanation: permitted_params[:explanation],
                    status: :in_progress,
                    provider: :other)
    @payment.cancel_payment_intent
    @payment.reload

    Rails.logger.info("#sent() => @payment #{@payment.inspect}")

    flash[:notice] = "We've recorded that your payment is en route"
    redirect_to event_ticket_requests_path(@event, @ticket_request)
  end

  private

  def mark_payment_completed
    Payment.transaction do
      # if we have a payment explanation, mark as other. else mark received
      @payment.mark_received
      @payment.ticket_request.mark_complete
      @payment.reload

      flash.now[:notice] = 'Payment has been received and marked as completed.'

      # Deliver the email asynchronously
      PaymentMailer.payment_received(@payment).deliver_later
    rescue StandardError => e
      Rails.logger.error("#mark_payment_completed() => error marking payment as received: #{e.message}")
      flash.now[:error] = "ERROR: #{e.message}"
      render_flash(flash)
    end
  end

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
    elsif permitted_params[:ticket_request_id].present?
      @payment = Payment.where(ticket_request_id: permitted_params[:ticket_request_id]).first
    elsif permitted_params[:id].present?
      @payment = Payment.find(permitted_params[:id])
    else
      true
    end
  end

  def initialize_payment
    @stripe_publishable_api_key ||= Rails.configuration.stripe[:publishable_api_key]

    @user = @ticket_request.user
    @payment = @ticket_request&.payment || @ticket_request&.build_payment
    Rails.logger.debug { "PaymentsController: initialize_payment: #{@payment&.inspect}" }
  end

  # @description Redirect the user if the payment can not be applied to the ticket request
  def validate_payment
    Rails.logger.debug { "PaymentsController: validate_payment @ticket_request #{@ticket_request&.inspect}" }

    unless @event.ticket_sales_open?
      return redirect_to event_path(@event),
                         alert: "Sorry, ticket sales for #{@event.name} have closed."
    end

    unless @ticket_request.owner?(current_user)
      Rails.logger.debug { "PaymentsController: @ticket_request #{@ticket_request.id} NOT OWNER current_user: #{@user&.inspect}" }
      return redirect_to root_path,
                         alert: 'You are not authorized to make payments for this ticket request.'
    end

    unless @ticket_request.all_guests_specified?
      Rails.logger.debug { "PaymentsController: @ticket_request guests not specified: #{@ticket_request&.inspect}" }
      return redirect_to edit_event_ticket_request_path(@event, @ticket_request),
                         alert: 'You must fill out all your guests before you can purchase a ticket.'
    end

    Rails.logger.debug { "PaymentsController: valid payment #{@payment&.inspect}" }
    true
  end

  # ensure we have a valid payment in progress that is not received
  def validate_payment_confirmation
    if @payment.received?
      Rails.logger.info("Payment Confirmation already received: #{@payment.id} status: #{@payment.status}")
      return root_path, information: 'This payment request has been confirmed! Thank you!'
    end

    unless @payment.in_progress?
      Rails.logger.info("Payment Confirmation not in progress: #{@payment.id} status: #{@payment.status}")
      return root_path, alert: 'This payment request can not be confirmed'
    end

    # has to have a stripe payment id and payment must not already be received
    unless @payment.stripe_payment?
      Rails.logger.error("Invalid payment confirmation id: #{@payment.id} missing stripe_payment_id")
      return root_path, alert: 'This payment request is not a valid stripe payment.'
    end

    nil
  end

  def permitted_params
    params.permit(
      :id,
      :event_id,
      :ticket_request_id,
      :stripe_payment_id,
      :payment_intent,
      :provider,
      :explanation,
      payment: %i[
        ticket_request
        ticket_request_id
        ticket_request_attributes
        status
      ]
    )
          .to_hash
          .with_indifferent_access
  end
end
