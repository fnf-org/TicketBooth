# frozen_string_literal: true

FactoryBot.define do
  factory :ticket_request_event_addon do
    event_addon
    ticket_request
    quantity { 1 }
  end
end
