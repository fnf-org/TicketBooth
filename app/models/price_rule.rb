# frozen_string_literal: true

# == Schema Information
#
# Table name: price_rules
#
#  id            :bigint           not null, primary key
#  price         :decimal(8, 2)
#  trigger_value :integer
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  event_id      :bigint
#
# Indexes
#
#  index_price_rules_on_event_id  (event_id)
#
class PriceRule < ApplicationRecord
  belongs_to :event

  attr_accessible :event, :price, :trigger_value, :type

  validates :price,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :trigger_value, presence: true,
                            numericality: { greater_than_or_equal_to: 0 }

  # The price rule that returns the smallest non-nil value is used to calculate
  # its respective portion of the price for the ticket request.
  def calc_price(ticket_request)
    raise NotImplementedError, 'Must implement in subclass'
  end
end
