# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                :bigint           not null, primary key
#  explanation       :string
#  status            :string(1)        default("P"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stripe_charge_id  :string(255)
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

  def save_and_charge!
    if valid?
      cost = ticket_request.cost
      amount_to_charge = cost + extra_amount_to_charge(cost)
      amount_to_charge_cents = (amount_to_charge * 100).to_i

      charge = Stripe::Charge.create(
        amount: amount_to_charge_cents,
        currency: 'usd',
        card: stripe_card_token,
        description: "#{ticket_request.event.name} Ticket"
      )

      self.stripe_charge_id = charge.id
      self.status = STATUS_RECEIVED
      save
    end
  rescue Stripe::StripeError => e
    errors.add :base, e.message
    false
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
