FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }

    factory :admin_user do
      admin { true }
    end
  end
end