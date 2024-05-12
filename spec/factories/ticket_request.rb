# frozen_string_literal: true

FactoryBot.define do
  factory :ticket_request do
    adults { event&.max_adult_tickets_per_request || 1 }
    kids { Random.rand(2) }
    cabins { Random.rand(2) }
    needs_assistance { [true, false].sample }
    notes { Faker::Lorem.paragraph }
    agrees_to_terms { true }
    guests { [Faker::Name.name, Faker::Name.name, Faker::Name.name] }

    user
    event

    trait :pending do |*|
      status { TicketRequest::STATUS_PENDING }
    end

    trait :approved do |*|
      status { TicketRequest::STATUS_AWAITING_PAYMENT }
    end

    trait :declined do |*|
      status { TicketRequest::STATUS_DECLINED }
    end
  end
end
