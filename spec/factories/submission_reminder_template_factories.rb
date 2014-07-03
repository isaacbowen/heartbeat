FactoryGirl.define do
  factory :submission_reminder_template do
    submissions_start_date { Date.today.at_beginning_of_week - 1.week }
    submissions_end_date { Date.today.at_beginning_of_week }
    medium 'email'
    subject { Faker::Lorem.sentence }
    template 'sup {{submission.url}}'
  end
end
