FactoryGirl.define do
  factory :metric do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    active true

    factory :inactive_metric do
      active false
    end

    factory :required_metric do
      required true
    end
  end
end