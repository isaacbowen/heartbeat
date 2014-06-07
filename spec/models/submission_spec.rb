require 'spec_helper'

describe Submission do

  describe '#seed_metrics!' do
    before(:each) do
      create_list :metric, 5
      create_list :inactive_metric, 3
    end

    it 'should seed based on the active set of metrics' do
      submission = build :submission

      submission.submission_metrics.should be_empty
      submission.seed_metrics!
      submission.submission_metrics.map(&:metric).should == Metric.active.all
    end

    context 'when submission metrics already exist' do
      it 'should do pretty much nothing' do
        submission = build :submission
        submission.submission_metrics = [build(:submission_metric, submission: submission)]

        submission.save!

        submission.submission_metrics.size.should == 1
      end
    end
  end

  describe '#completed?' do
    it 'should jive with our factories' do
      create(:submission).should_not be_completed
      create(:completed_submission).should be_completed
    end

    it 'should be committed when saved' do
      submission = create :submission, submission_metrics: build_list(:submission_metric, 5)

      submission[:completed].should be_false
      submission.should_not be_completed

      submission.submission_metrics.each { |sm| sm.rating = 3; sm.save! }
      submission.comments = 'foobar'
      submission.save!

      submission[:completed].should be_true
      submission.should be_completed
    end

    context 'with no submission metrics' do
      it 'should be incomplete' do
        submission = create :submission, submission_metrics: []

        submission.submission_metrics.should be_empty
        submission.should_not be_completed
      end
    end

    context 'with no required metrics' do
      context 'with at least one complete metric' do
        it 'should be complete' do
          submission = create :submission, submission_metrics: build_list(:submission_metric, 5)
          submission.submission_metrics << build(:completed_submission_metric)

          submission.should be_completed
        end
      end

      context 'with none complete' do
        it 'should be incomplete' do
          submission = create :submission, submission_metrics: build_list(:submission_metric, 5)

          submission.should_not be_completed
        end
      end
    end

    context 'with some incomplete required metrics' do
      it 'should be incomplete' do
        submission = create :submission, submission_metrics: build_list(:submission_metric, 5)
        submission.submission_metrics << build(:required_submission_metric)

        submission.should_not be_completed
      end
    end

    context 'with some complete required metrics' do
      it 'should be complete' do
        submission = create :submission, submission_metrics: build_list(:completed_submission_metric, 5)
        submission.submission_metrics << create(:required_submission_metric, rating: 4)

        submission.should be_completed
      end
    end

  end

end
