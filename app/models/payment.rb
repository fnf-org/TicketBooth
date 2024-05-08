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
#  stripe_charge_id  :string(255)      # PaymentIntent ID
#  ticket_request_id :integer          not null
#
class Payment < ApplicationRecord
  include PaymentsHelper

  STATUSES = [
    STATUS_IN_PROGRESS = 'P',
    STATUS_RECEIVED = 'R'
  ].freeze

  belongs_to :ticket_request

  attr_accessible :ticket_request_id, :ticket_request_attributes, :status,
                  :stripe_card_token, :explanation

  accepts_nested_attributes_for :ticket_request,
                                reject_if: :modifying_forbidden_attributes?

  attr_accessor :stripe_card_token

  validates :ticket_request,
            uniqueness: { message: 'ticket request has already been paid' }
  validates :status, presence: true, inclusion: { in: STATUSES }

  def save_with_payment_intent!
    unless valid?
      errors.add(:base, 'Invalid Ticket Request')
      return false
    end

    begin
      cost = calculate_cost

      @payment_intent = create_payment_intent(cost)

      self.stripe_charge_id = @payment_intent.id
      self.status = STATUS_RECEIVED

      save

    rescue Stripe::StripeError => e
      errors.add :base, e.message
      false
    end
  end


  # Ticket Cost
  def calculate_cost
    cost = ticket_request.cost

    # XXX disabled for now
    amount_to_charge = cost + extra_amount_to_charge(cost)
    (amount_to_charge * 100).to_i
  end

  # Stripe Payment Intent
  # https://docs.stripe.com/api/payment_intents/object
  def create_payment_intent(amount_to_charge)
    Stripe::PaymentIntent.create({
      amount: amount_to_charge,
      currency: 'usd',
      automatic_payment_methods: {enabled: true},
      description: "#{ticket_request.event.name} Ticket",
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
    Stripe::PaymentIntent.retrieve(self.stripe_charge_id) if self.stripe_charge_id
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
    stripe_charge_id
  end

  private

  def modifying_forbidden_attributes?(attributed)
    # Only allow donation field to be updated
    attributed.any? do |attribute, _value|
      %w[donation id].exclude?(attribute.to_s)
    end
  end
end
