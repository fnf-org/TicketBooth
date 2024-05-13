# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first { Faker::Name.first_name }
    last { Faker::Name.last_name }
    name { "#{first} #{last}" }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }

    trait :confirmed do |*|
      confirmed_at { Time.current }
    end

    trait :site_admin do
      site_admin
    end
  end
end
