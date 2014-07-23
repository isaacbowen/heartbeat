# == Schema Information
#
# Table name: submissions
#
#  id              :uuid             not null, primary key
#  user_id         :uuid
#  completed       :boolean          default(FALSE), not null
#  completed_at    :datetime
#  comments        :string(140)
#  created_at      :datetime
#  updated_at      :datetime
#  comments_public :boolean          default(TRUE)
#  tags            :string(255)      default([]), is an Array
#

require 'spec_helper'

describe Submission do

  subject { create :submission }

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

  describe '#previous' do
    it 'should be the previous submission for the user' do
      user = create :user
      previous_submissions = []

      (1..3).each do |i|
        Timecop.travel i.days.ago
        previous_submissions << create(:submission, user: user)
        Timecop.return
      end

      submission = create :submission, user: user
      submission.previous.should == previous_submissions.first
    end
  end

  describe '#closed?' do
    it 'should hinge on the one week mark' do
      submission = create :submission
      submission.should_not be_closed
      submission.update_column :created_at, (1.week.ago + 1.day)
      submission.should_not be_closed
      submission.update_column :created_at, (1.week.ago - 1.day)
      submission.should be_closed
    end
  end

  describe '#rating' do
    it 'should be the average of all ratings, if complete' do
      submission = create :submission
      submission.should_not be_completed
      submission.rating.should be_nil

      submission = create :completed_submission
      submission.should be_completed
      submission.rating.should == submission.submission_metrics.average(:rating)
    end
  end

  describe '#url' do
    specify { subject.url.should == "http://heartbeat.dev/submissions/#{subject.id}" }
  end

  describe '#to_liquid' do
    specify do
      subject.to_liquid.should == {
        'url' => "http://heartbeat.dev/submissions/#{subject.id}",
      }
    end
  end

end
