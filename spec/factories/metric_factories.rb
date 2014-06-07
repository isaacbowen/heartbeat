FactoryGirl.define do
  factory :metric do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
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