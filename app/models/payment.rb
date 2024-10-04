# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                :bigint           not null, primary key
#  explanation       :string
#  old_status        :string(1)        default("N"), not null
#  provider          :enum             default("stripe"), not null
#  status            :enum             default("new"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stripe_charge_id  :string(255)
#  stripe_payment_id :string
#  stripe_refund_id  :string
#  ticket_request_id :integer          not null
#
# Indexes
#
#  index_payments_on_stripe_payment_id  (stripe_payment_id)
#

# @description Payment record from Provider
# @deprecated stripe_charge_id

class Payment < ApplicationRecord
  enum :provider, { stripe: 'stripe', cash: 'cash', other: 'other' }, prefix: true
  enum :status, { new: 'new', in_progress: 'in_progress', received: 'received', refunded: 'refunded' }, prefix: true

  # in case of destroy, clean up any open payment intent
  before_destroy :cancel_payment_intent

  belongs_to :ticket_request

  attr_accessible :ticket_request_id, :ticket_request_attributes,
                  :status, :provider, :stripe_payment_id, :explanation

  # stripe payment objects
  attr_accessor   :payment_intent, :refund

  accepts_nested_attributes_for :ticket_request,
                                reject_if: :modifying_forbidden_attributes?

  validates :ticket_request, uniqueness: { message: 'ticket request has already been paid' }

  delegate :can_view?, to: :ticket_request

  # Create new Payment with Stripe PaymentIntent
  # Set status Payment
  def save_with_payment_intent
    # only save 1 payment intent
    unless valid?
      errors.add :base, 'Invalid Payment'
      return false
    end

    # calculate cost from Ticket Request
    cost = calculate_cost
    Rails.logger.debug { "save_with_payment_intent: cost => #{cost}}" }

    begin
      # Create new Stripe PaymentIntent (external Stripe API)
      self.payment_intent = create_payment_intent(cost)
      log_intent(payment_intent)
      self.stripe_payment_id = payment_intent.id
    rescue Stripe::StripeError => e
      errors.add :base, e.message
      false
    end

    # stripe payment is in progress
    self.provider = :stripe unless provider_stripe?
    self.status   = :in_progress unless status_in_progress?

    save
    payment_intent
  end

  def retrieve_or_save_payment_intent
    Rails.logger.debug { "retrieve_or_save_payment_intent payment => #{inspect}}" }
    return payment_intent if payment_in_progress?

    if stripe_payment? && payment_intent.blank?
      # retrieve Payment Intent from Stripe payment
      retrieve_payment_intent
    else
      # generate and save new stripe payment intent
      save_with_payment_intent
    end

    log_intent(payment_intent)
    payment_intent
  end

  # Calculate ticket cost from ticket request in cents
  def calculate_cost
    cost  = ticket_request.cost
    (cost * 100).to_i
  end

  def dollar_cost
    (calculate_cost / 100).to_i
  end

  # Stripe Payment Intent
  # https://docs.stripe.com/api/payment_intents/object
  def create_payment_intent(amount)
    Stripe::PaymentIntent.create({
                                   amount:,
                                   currency:                  'usd',
                                   automatic_payment_methods: { enabled: true },
                                   description:               "#{ticket_request.event.name} Tickets",
                                   metadata:                  {
                                     event_id:               ticket_request.event.id,
                                     event_name:             ticket_request.event.name,
                                     ticket_request_id:      ticket_request.id,
                                     ticket_request_user_id: ticket_request.user_id,
                                     payment_id:             id
                                   }
                                 })
  end

  def update_payment_intent_amount(amount)
    self.payment_intent = Stripe::PaymentIntent.update(stripe_payment_id, { amount: })
  end

  def payment_intent_client_secret
    payment_intent&.client_secret
  end

  def retrieve_payment_intent
    return unless stripe_payment?

    self.payment_intent = Stripe::PaymentIntent.retrieve(stripe_payment_id)

    # check if we have the same cost
    if payment_intent.amount != (amount = calculate_cost)
      self.payment_intent = update_payment_intent_amount(amount)
      Rails.logger.info { "retrieve_payment_intent updated payment intent with new amount [#{amount}] => #{payment_intent}}" }
    end

    Rails.logger.debug { "retrieve_payment_intent payment => #{inspect}}" }
    self.payment_intent
  end

  # cancel Stripe PaymentIntent if is in progress
  def cancel_payment_intent
    return unless stripe_payment? && status_in_progress?

    Rails.logger.info "cancel_payment_intent: #{id} provider: #{provider} stripe_payment_id: #{stripe_payment_id} status: #{status}"
    response = Stripe::PaymentIntent.cancel(stripe_payment_id, { cancellation_reason: 'requested_by_customer' })
    self.payment_intent = response if response.present?
  end

  # https://docs.stripe.com/api/refunds
  # refund Stripe payment
  # reasons duplicate, fraudulent, or requested_by_customer
  def refund_stripe_payment(reason: 'requested_by_customer')
    return false unless received?

    begin
      Rails.logger.info "refund_stripe_payment: #{id} stripe_payment_id: #{stripe_payment_id} status: #{status}"
      self.refund = Stripe::Refund.create({ payment_intent: stripe_payment_id,
                                            reason:,
                                            metadata:       { event_id:               ticket_request.event.id,
                                                              event_name:             ticket_request.event.name,
                                                              ticket_request_id:      ticket_request.id,
                                                              ticket_request_user_id: ticket_request.user_id } })
      self.stripe_refund_id = refund.id
      self.status = :refunded
      Rails.logger.info { "refund_stripe_payment success stripe_refund_id [#{stripe_refund_id}] status [#{status}]" }
      log_refund(refund)
      save!
    rescue Stripe::StripeError => e
      Rails.logger.error { "refund_stripe_payment Stripe::Refund.create failed [#{stripe_payment_id}]: #{e}" }
      errors.add :base, e.message
      false
    rescue StandardError => e
      Rails.logger.error("#{e.class.name} ERROR during a refund: #{e.message.colorize(:red)}")
      false
    end
  end

  def payment_in_progress?
    payment_intent.present? && status_in_progress?
  end

  def status_name
    status.humanize
  end

  def in_progress?
    status_in_progress?
  end

  def stripe_payment?
    provider_stripe? && stripe_payment_id.present?
  end

  def received?
    stripe_payment? && status_received?
  end

  def refunded?
    stripe_payment? && status_refunded?
  end

  def refundable?
    received?
  end

  # @deprecated method for converting old status
  def convert_old_status!
    @matrix ||= { 'N' => 'new', 'P' => 'in progress', 'R' => 'received', 'F' => 'refunded' }
    self.status = @matrix[old_status]
    save!
  end

  # Manually mark that a payment was received.
  def mark_received
    status_received!
  end

  # In transaction,
  # mark payment received and ticket request completed
  # Send off PaymentMailer for payment received
  def request_completed
    mark_received
    ticket_request.mark_complete

    # Deliver the email asynchronously
    PaymentMailer.payment_received(self).deliver_later

    self.reload
  end

  private

  def log_intent(payment_intent)
    intent_amount = '$%.2f'.colorize(:red) % (payment_intent['amount'].to_i / 100.0)
    Rails.logger.info "Payment Intent => id: #{payment_intent['id'].colorize(:yellow)}, " \
                      "status: #{payment_intent['status'].colorize(:green)}, " \
                      "for user: #{ticket_request.user.email.colorize(:blue)}, " \
                      "amount: #{intent_amount}"
  end

  def log_refund(refund)
    refund_amount = '$%.2f'.colorize(:red) % (refund['amount'].to_i / 100.0)
    Rails.logger.info "Refund => id: #{refund['id'].colorize(:yellow)}, " \
                      "status: #{refund['status'].colorize(:green)}, " \
                      "for user: #{ticket_request.user.email.colorize(:blue)}, " \
                      "amount: #{refund_amount}"
  end

  def modifying_forbidden_attributes?(attributed)
    # Only allow donation field to be updated
    attributed.any? do |attribute, _value|
      %w[donation id].exclude?(attribute.to_s)
    end
  end
end
