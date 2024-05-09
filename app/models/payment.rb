# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                :integer          not null, primary key
#  explanation       :string(255)
#  status            :string(1)        default("P"), not null
#  created_at        :datetime
#  updated_at        :datetime
#  stripe_charge_id  :string(255)      # deprecated as of 2024
#  stripe_payment_id :string(255)
#  ticket_request_id :integer          not null
#
class Payment < ApplicationRecord
  include PaymentsHelper

  STATUSES = [
    STATUS_IN_PROGRESS = 'P',
    STATUS_RECEIVED = 'R'
  ].freeze

  belongs_to :ticket_request

  # XXX [mfl] I think we can kill stripe_card_token
  attr_accessible :ticket_request_id, :ticket_request_attributes, :status,
                  :stripe_payment_id, :explanation

  accepts_nested_attributes_for :ticket_request,
                                reject_if: :modifying_forbidden_attributes?

  attr_accessor :stripe_card_token

  validates :ticket_request,
            uniqueness: { message: 'ticket request has already been paid' }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # Create new Payment
  # Create Stripe PaymentIntent
  # Set status Payment
  def save_with_payment_intent!
      cost = calculate_cost

      begin
        @payment_intent = create_payment_intent(cost)
        self.stripe_payment_id = @payment_intent.id

      rescue Stripe::StripeError => e
        errors.add :base, e.message
        false
      end

      self.status = STATUS_IN_PROGRESS

      save!
      self
  end

  # Calculate ticket cost from ticket request
  def calculate_cost
    cost = ticket_request.cost
    amount_to_charge = cost + extra_amount_to_charge(cost)
    (amount_to_charge * 100).to_i
  end

  # Stripe Payment Intent
  # https://docs.stripe.com/api/payment_intents/object
  def create_payment_intent(amount)
    Stripe::PaymentIntent.create({
      amount: amount,
      currency: 'usd',
      automatic_payment_methods: {enabled: true},
      description: "#{ticket_request.event.name} Tickets",
      metadata: {
        ticket_request_id: ticket_request.id,
        ticket_request_user_id: ticket_request.user_id,
        event_id: ticket_request.event.id,
        event_name: ticket_request.event.name
      }
    })
  end

  def payment_intent
    @payment_intent ||= get_payment_intent
  end

  def payment_intent_client_secret
    @payment_intent_client_secret ||= payment_intent.client_secret
  end

  def get_payment_intent
    Stripe::PaymentIntent.retrieve(self.stripe_payment_id) if self.stripe_payment_id
  end

  # Manually mark that a payment was received.
  def mark_received
    self.status = STATUS_RECEIVED
    save!
  end

  delegate :can_view?, to: :ticket_request

  def due_date
    (created_at + 2.weeks).to_date
  end

  def in_progress?
    status == STATUS_IN_PROGRESS
  end

  def received?
    status == STATUS_RECEIVED
  end

  def via_credit_card?
    stripe_payment_id
  end

  private

  def modifying_forbidden_attributes?(attributed)
    # Only allow donation field to be updated
    attributed.any? do |attribute, _value|
      %w[donation id].exclude?(attribute.to_s)
    end
  end
end
