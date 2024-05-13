# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                :integer          not null, primary key
#  explanation       :string(255)
#  status            :string(1)        default("N"), not null
#  created_at        :datetime
#  updated_at        :datetime
#  stripe_charge_id  :string(255)
#  stripe_payment_id :string
#  ticket_request_id :integer          not null
#
# Indexes
#
#  index_payments_on_stripe_payment_id  (stripe_payment_id)
#

# @description Payment record from Stripe
# @deprecated stripe_charge_id
class Payment < ApplicationRecord
  include PaymentsHelper

  # TOOD: Change to Enum
  STATUSES = [
    STATUS_NEW         = 'N',
    STATUS_IN_PROGRESS = 'P',
    STATUS_RECEIVED    = 'R'
  ].freeze

  STATUS_NAMES = {
    'N' => 'New',
    'P' => 'In Progress',
    'R' => 'Received'
  }.freeze

  belongs_to :ticket_request

  attr_accessible :ticket_request_id, :ticket_request_attributes,
                  :status, :stripe_payment_id, :explanation

  accepts_nested_attributes_for :ticket_request,
                                reject_if: :modifying_forbidden_attributes?

  validates :ticket_request, uniqueness: { message: 'ticket request has already been paid' }
  validates :status, presence: true, inclusion: { in: STATUSES }

  attr_accessor :payment_intent

  # Create new Payment
  # Create Stripe PaymentIntent
  # Set status Payment
  def save_with_payment_intent
    # only save 1 payment intent
    unless valid?
      errors.add :base, 'Invalid Payment'
      return false
    end

    # calculate cost from Ticket Request
    cost = calculate_cost

    begin
      # Create new Stripe PaymentIntent
      self.payment_intent = create_payment_intent(cost)
      log_intent(payment_intent)
      self.stripe_payment_id = payment_intent.id
    rescue Stripe::StripeError => e
      errors.add :base, e.message
      false
    end

    # payment is in progress, not completed
    self.status = STATUS_IN_PROGRESS

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
    cost             = ticket_request.cost
    amount_to_charge = cost + extra_amount_to_charge(cost)
    (amount_to_charge * 100).to_i
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
                                     ticket_request_id:      ticket_request.id,
                                     ticket_request_user_id: ticket_request.user_id,
                                     event_id:               ticket_request.event.id,
                                     event_name:             ticket_request.event.name
                                   }
                                 })
  end

  def payment_intent_client_secret
    payment_intent&.client_secret
  end

  def retrieve_payment_intent
    return unless stripe_payment_id

    self.payment_intent = Stripe::PaymentIntent.retrieve(stripe_payment_id)
  end

  def payment_in_progress?
    payment_intent.present? && status == STATUS_IN_PROGRESS
  end

  def status_name
    STATUS_NAMES[status]
  end

  # Manually mark that a payment was received.
  def mark_received
    update status: STATUS_RECEIVED
  end

  delegate :can_view?, to: :ticket_request

  def in_progress?
    status == STATUS_IN_PROGRESS
  end

  def received?
    status == STATUS_RECEIVED
  end

  def stripe_payment?
    stripe_payment_id.present?
  end

  private

  def log_intent(payment_intent)
    intent_amount = '$%.2f'.colorize(:red) % (payment_intent['amount'].to_i / 100.0)
    Rails.logger.info "Payment Intent => id: #{payment_intent['id'].colorize(:yellow)}, " \
                      "status: #{payment_intent['status'].colorize(:green)}, for user: #{ticket_request.user.email.colorize(:blue)}, amount: #{intent_amount}"
  end

  def modifying_forbidden_attributes?(attributed)
    # Only allow donation field to be updated
    attributed.any? do |attribute, _value|
      %w[donation id].exclude?(attribute.to_s)
    end
  end
end
