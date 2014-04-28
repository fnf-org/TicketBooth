FactoryGirl.define do
  factory :user do
    name { Sham.words(2) }
    email { Sham.email_address }
    password 'password'
    password_confirmation 'password'

    trait :site_admin do
      after :create do |user|
        SiteAdmin.make! user: user
      end
    end
  end
end
