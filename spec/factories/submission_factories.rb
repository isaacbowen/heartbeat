FactoryGirl.define do
  factory :submission do
    user
    comments { Faker::Lorem.sentence }

    factory :completed_submission do
      after(:build) do |submission|
        submission.submission_metrics = build_list :completed_submission_metric, 5, submission: submission
      end
    end
  end
end