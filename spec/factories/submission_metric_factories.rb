FactoryGirl.define do
  factory :submission_metric do
    submission
    metric

    factory :completed_submission_metric do
      rating { SubmissionMetric::VALID_RATINGS.sample }
      comments { Faker::Lorem.sentence }
    end
  end
end