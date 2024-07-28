# frozen_string_literal: true

FactoryBot.define do
  factory :event_addon do
    event
    addon
    price { 10 }
  end
end
