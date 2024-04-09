# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Sham.words(2) }
    email { Sham.email_address }
    password { 'password' }

    trait :site_admin do
      after :create do |user|
        SiteAdmin.make! user:
      end
    end
  end
end
