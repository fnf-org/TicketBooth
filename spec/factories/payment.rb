# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    ticket_request
    status { Payment::STATUS_NEW }
  end
end
