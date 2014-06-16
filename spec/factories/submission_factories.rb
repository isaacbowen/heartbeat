FactoryGirl.define do
  factory :submission do
    user
    comments { Faker::Lorem.sentence }

    factory :completed_submission do
      after(:build) do |submission|
        submission.submission_metrics = begin
          if Metric.all.any?
            Metric.all.map do |metric|
              build :completed_submission_metric, submission: submission, metric: metric
            end
          else
            build_list :completed_submission_metric, 5, submission: submission
          end
        end
      end
    end
  end
end