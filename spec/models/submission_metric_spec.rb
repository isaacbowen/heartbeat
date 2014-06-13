# == Schema Information
#
# Table name: submission_metrics
#
#  id            :uuid             not null, primary key
#  submission_id :uuid
#  metric_id     :uuid
#  rating        :integer
#  comments      :text
#  completed     :boolean          default(FALSE), not null
#  completed_at  :datetime
#

require 'spec_helper'

describe SubmissionMetric do

  subject { create :submission_metric }

  describe '#completed?' do
    it 'should be based on rating' do
      subject.stub(:rating) { nil }
      subject.should_not be_completed
      subject.stub(:rating) { 5 }
      subject.should be_completed
    end
  end

  describe '#rating=' do
    it 'should filter based on VALID_RATINGS' do
      stub_const 'SubmissionMetric::VALID_RATINGS', [1, 2, 3]
      subject.rating = 4
      subject.rating.should be_nil
      [1, 2, 3].each do |i|
        subject.rating = i
        subject.rating.should == i
      end
    end
  end

  describe '#name' do
    it 'should == metric.name' do
      subject.name.should == subject.metric.name
    end
  end

  describe '#description' do
    it 'should == metric.description' do
      subject.description.should == subject.metric.description
    end
  end

  describe '#previous' do
    it 'should be the previous metric, for the previous submission, for the user' do
      create_list :metric, 4

      user = create :user
      previous_submissions = []

      (1..3).to_a.each do |i|
        Timecop.travel i.days.ago
        previous_submissions << create(:submission, user: user)
        Timecop.return
      end

      submission = create :submission, user: user
      submission.submission_metrics.map(&:previous).should == previous_submissions.first.submission_metrics
    end
  end

end
