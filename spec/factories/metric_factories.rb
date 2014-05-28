FactoryGirl.define do
  factory :metric do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    active true

    factory :inactive_metric do
      active false
    end
  end
end