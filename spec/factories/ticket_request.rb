# frozen_string_literal: true

FactoryBot.define do
  factory :ticket_request do
    adults { Random.rand(1..4) }
    kids { Random.rand(0..2) }
    cabins { Random.rand(0..2) }
    needs_assistance { [true, false].sample }
    notes { Sham.words(10) }
    agrees_to_terms true
    user
    event

    trait :pending do |_ticket_request|
      status TicketRequest::STATUS_PENDING
    end

    trait :approved do |_ticket_request|
      status TicketRequest::STATUS_AWAITING_PAYMENT
    end

    trait :declined do |_ticket_request|
      status TicketRequest::STATUS_DECLINED
    end
  end
end
