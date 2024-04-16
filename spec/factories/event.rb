# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { Faker::FunnyName.three_word_name }
    start_time { 1.year.from_now }
    end_time { (1.year.from_now + 1.day) }

    adult_ticket_price { Random.rand(100..150) }
    kid_ticket_price { Random.rand(40..50) }
    cabin_price { nil }
    max_adult_tickets_per_request { Random.rand(2..4) }
    max_kid_tickets_per_request { 2 }
    max_cabins_per_request { nil }
    tickets_require_approval { true }

    trait :kids_tickets_available do
      kid_ticket_price { Random.rand(10) }
    end

    trait :cabins_available do
      cabin_price { Random.rand(100) }
      max_cabins_per_request { Random.rand(1...1) }
    end

    trait :with_admins do
      after(:create) do |event|
        create_list(:event_admin, 2, event:)
      end
    end
  end
end
