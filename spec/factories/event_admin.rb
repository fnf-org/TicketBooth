# frozen_string_literal: true

FactoryBot.define do
  factory :event_admin do
    event
    user
  end
end
