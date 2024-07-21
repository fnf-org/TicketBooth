# frozen_string_literal: true

FactoryBot.define do
  factory :addon do
    category { Addon::CATEGORY_PASS }
    name { 'Backstage' }
    default_price { '20' }
  end
end
