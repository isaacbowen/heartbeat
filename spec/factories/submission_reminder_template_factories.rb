FactoryGirl.define do
  factory :submission_reminder_template do
    medium 'email'
    subject { Faker::Lorem.sentence }
    template 'sup {{submission.url}}'
  end
end
