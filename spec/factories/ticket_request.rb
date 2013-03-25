FactoryGirl.define do
  factory :ticket_request do
    status TicketRequest::STATUS_PENDING
    address { Sham.street_address }
    adults { Random.rand(1..4) }
    kids { Random.rand(0..2) }
    cabins { Random.rand(0..2) }
    needs_assistance { [true, false].sample }
    notes { Sham.words(10) }

    association :user
    association :event

    trait :pending do |ticket_request|
      status TicketRequest::STATUS_PENDING
    end

    trait :approved do |ticket_request|
      status TicketRequest::STATUS_APPROVED
    end

    trait :declined do |ticket_request|
      status TicketRequest::STATUS_DECLINED
    end
  end
end
