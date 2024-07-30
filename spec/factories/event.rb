# frozen_string_literal: true

SEASONS = %w[Summer Fall Spring Winter].freeze

FactoryBot.define do
  factory :event do
    name { "FnF #{SEASONS[Random.rand(4)]} Campout #{Random.rand(30).to_roman}" }
    start_time { 1.year.from_now }
    end_time { (1.year.from_now + 1.day) }

    adult_ticket_price { Random.rand(100..150) }
    kid_ticket_price { Random.rand(40..50) }
    max_adult_tickets_per_request { Random.rand(2..4) }
    max_kid_tickets_per_request { 2 }
    tickets_require_approval { true }

    trait :kids_tickets_available do
      kid_ticket_price { Random.rand(10) }
    end

    trait :with_admins do
      after(:create) do |event|
        create_list(:event_admin, 2, event:)
      end
    end
  end
end
