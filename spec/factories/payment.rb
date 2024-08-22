# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    ticket_request
    stripe_payment_id { SecureRandom.hex }
  end
end
