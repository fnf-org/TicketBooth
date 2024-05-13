# frozen_string_literal: true

# @description
#   Calculates the extra amount to charge based off of Stripe's fees
module PaymentsHelper
  # 2.9% per transaction
  STRIPE_RATE = BigDecimal('0.029', 10)

  # +30 cents per transaction
  STRIPE_TRANSACTION_FEE = BigDecimal('0.30', 10)

  class << self
    attr_accessor :extra_fees_enabled, :stripe_rate, :stripe_transaction_fee

    def configure
      self.extra_fees_enabled = false
      self.stripe_rate = STRIPE_RATE
      self.stripe_transaction_fee = STRIPE_TRANSACTION_FEE

      # override in a block
      yield(self)
    end

    def disable!
      self.extra_fees_enabled = false
    end
  end

  # @description
  #   For now, we disable passing fees on to user.

  attr_accessor :extra_charge_amount

  # @description
  #   Can be used to tack on additional fees to the user.
  def extra_amount_to_charge(original_amount_cents = nil)
    unless PaymentsHelper.extra_fees_enabled
      return self.extra_charge_amount = 0
    end

    if original_amount_cents.nil? && respond_to?(:amount)
      original_amount_cents = amount
    end

    extra = ((original_amount_cents * STRIPE_RATE) + STRIPE_TRANSACTION_FEE) / (1 - STRIPE_RATE)
    self.extra_charge_amount = extra.ceil # Round up to the nearest cent
  end
end

PaymentsHelper.disable!
