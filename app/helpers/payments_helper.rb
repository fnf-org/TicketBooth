# frozen_string_literal: true

module PaymentsHelper
  # Calculates the extra amount to charge based off of Stripe's fees so that the
  # full original amount is sent to the event organizer.
  STRIPE_RATE = BigDecimal('0.029', 10) # 2.9% per transaction
  STRIPE_TRANSACTION_FEE = BigDecimal('0.30', 10) # +30 cents per transaction
  def extra_amount_to_charge(_original_amount)
    # XXX: For now, disable passing fees on to user
    # extra = (original_amount * STRIPE_RATE + STRIPE_TRANSACTION_FEE) / (1 - STRIPE_RATE)
    # extra_cents = (extra * 100).ceil # Round up to the nearest cent
    # BigDecimal.new(extra_cents, 10) / 100
    0
  end
end
