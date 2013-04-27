FactoryGirl.define do
  factory :event_admin do
    association :event
    association :user
  end
end
