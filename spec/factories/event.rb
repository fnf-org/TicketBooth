FactoryGirl.define do
  factory :event do
    name { Sham.words(3) }
    start_time { 1.year.from_now }
    end_time { 1.year.from_now + 1.day }
  end
end
