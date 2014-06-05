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

end
