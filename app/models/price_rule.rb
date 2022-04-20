# frozen_string_literal: true

class PriceRule < ActiveRecord::Base
  belongs_to :event

  attr_accessible :event, :price, :trigger_value, :type

  validates :event_id, presence: true
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
