FactoryGirl.define do
  factory :submission_reminder do
    submission
    medium 'email'
    template 'sup {{submission.url}}'
  end
end
