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

    it 'should be invoked as part of creation' do
      submission = build :submission
      submission.submission_metrics.should be_empty

      submission.save!

      submission.submission_metrics.should_not be_empty
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

  describe '#complete?' do

    it 'should jive with our factories' do
      create(:submission).should_not be_complete
      create(:completed_submission).should be_complete
    end

    context 'with no submission metrics' do
      it 'should be incomplete' do
        submission = build :submission, submission_metrics: []
        submission.submission_metrics.should be_empty
        submission.should_not be_complete
      end
    end

    context 'with some incomplete metrics' do
      it 'should be incomplete' do
        submission = build :submission, submission_metrics: build_list(:submission_metric, 5)
        submission.should_not be_complete
      end
    end

    context 'with some complete metrics' do
      it 'should be complete' do
        submission = build :submission, submission_metrics: build_list(:completed_submission_metric, 5)
        submission.should be_complete
      end
    end

  end

end
