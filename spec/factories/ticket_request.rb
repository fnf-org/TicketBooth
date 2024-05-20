# frozen_string_literal: true

FactoryBot.define do
  factory :ticket_request do
    adults { 3 }
    kids { 1 }
    cabins { Random.rand(2) }
    needs_assistance { [true, false].sample }
    notes { Faker::Lorem.paragraph }
    agrees_to_terms { true }
    guests do
      [
        "#{Faker::Name.first_name} #{Faker::Name.last_name} <#{Faker::Internet.email}>",
        "#{Faker::Name.first_name} #{Faker::Name.last_name} <#{Faker::Internet.email}>"
      ]
    end

    guests_kids do
      [
        "#{Faker::Name.first_name} #{Faker::Name.last_name}, 2",
      ]
    end

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
