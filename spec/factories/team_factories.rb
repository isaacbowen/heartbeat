FactoryGirl.define do
  factory :team do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
  end
end
