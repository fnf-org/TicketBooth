# frozen_string_literal: true

FactoryBot.define do
  factory :eald_payment do
    event
    name { Faker::Name.name }
    early_arrival_passes { 10 }
    amount_charged_cents { 1000 }
    late_departure_passes { 5 }
    email { Faker::Internet.email }
    stripe_charge_id { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
