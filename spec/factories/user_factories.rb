FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    tags { [Faker::Lorem.word, Faker::Lorem.word, Faker::Lorem.word] }

    factory :admin_user do
      admin { true }
    end
  end
end