# frozen_string_literal: true

FactoryBot.define do
  factory :ticket_request do
    adults { Random.rand(1..4) }
    kids { Random.rand(2) }
    cabins { Random.rand(2) }
    needs_assistance { [true, false].sample }
    notes { Sham.words(10) }
    agrees_to_terms { true }

    user { FactoryBot.create(:user) }
    event { FactoryBot.create(:event) }

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
