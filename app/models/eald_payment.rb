# frozen_string_literal: true

# == Schema Information
#
# Table name: eald_payments
#
#  id                    :bigint           not null, primary key
#  amount_charged_cents  :integer          not null
#  early_arrival_passes  :integer          default(0), not null
#  email                 :string(255)      not null
#  late_departure_passes :integer          default(0), not null
#  name                  :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  event_id              :bigint
#  stripe_charge_id      :string           not null
#
# Indexes
#
#  index_eald_payments_on_event_id  (event_id)
#
class EaldPayment < ApplicationRecord
  include PaymentsHelper

  belongs_to :event

  attr_accessible :event_id, :name, :email, :early_arrival_passes, :late_departure_passes, :stripe_card_token

  validates :early_arrival_passes, presence: true,
                                   numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :late_departure_passes, presence: true,
                                    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  attr_accessor :stripe_card_token

  def save_and_charge!
    if valid?
      amount_to_charge = price + extra_amount_to_charge(price)
      amount_to_charge_cents = (amount_to_charge * 100).to_i

      charge = Stripe::Charge.create(
        amount: amount_to_charge_cents,
        currency: 'usd',
        card: stripe_card_token,
        description: "#{event.name} EA/LD Pass"
      )

      self.stripe_charge_id = charge.id
      self.amount_charged_cents = charge.amount
      save
    end
  rescue Stripe::StripeError => e
    errors.add :base, e.message
    false
  end

  def price
    (early_arrival_passes * event.early_arrival_price) +
      (late_departure_passes * event.late_departure_price)
  end
end
