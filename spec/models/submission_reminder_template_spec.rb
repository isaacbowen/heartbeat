# == Schema Information
#
# Table name: submission_reminder_templates
#
#  id                     :uuid             not null, primary key
#  submissions_start_date :date             not null
#  submissions_end_date   :date             not null
#  reify_at               :datetime
#  reified                :boolean          default(FALSE), not null
#  medium                 :text             not null
#  template               :text             not null
#  meta                   :hstore
#

require 'spec_helper'

describe SubmissionReminderTemplate do

  let(:start_date) { 5.days.ago }
  let(:end_date) { 2.days.ago }

  subject { create :submission_reminder_template, submissions_start_date: start_date, submissions_end_date: end_date }

  before(:each) do
    Timecop.travel(6.days.ago) { create_list :submission, 2 }
    Timecop.travel(3.days.ago) { create_list :submission, 3 }
    Timecop.travel(1.days.ago) { create_list :submission, 4 }
  end

  describe '#submissions' do
    it 'should be the matching range of submissions' do
      subject.submissions.size.should == 3
    end
  end

  describe '#reify!' do
    it 'should create matching submission reminders' do
      reminders = subject.reify!

      reminders.should_not be_empty

      reminders.all? { |r| r.medium == subject.medium }.should be_true
      reminders.all? { |r| r.subject == subject.subject }.should be_true
      reminders.all? { |r| r.from == subject.from }.should be_true
    end

    it 'should give us a set of submission reminders' do
      expect { subject.reify! }.to change { SubmissionReminder.count }.from(0).to(subject.submissions.size)
    end

    it 'should fill in the gaps' do
      subject.reify!

      Timecop.travel(3.days.ago) { create_list :submission, 2 }
      expect { subject.reify! }.to change { SubmissionReminder.count }.by(2)

      # nothing the second time around
      expect { subject.reify! }.to change { SubmissionReminder.count }.by(0)
    end

    it 'should mark the subject as reified' do
      expect { subject.reify! }.to change { subject.reified? }.from(false).to(true)
    end

    context 'when a problem occurs' do
      it 'should not mark the subject as reified' do
        # haaaack
        foo = false
        SubmissionReminder.any_instance.stub(:subject=) { raise 'asdf' if foo; foo = true }

        expect { subject.reify! rescue nil }.to_not change { subject.reified? }
        expect { subject.reify! rescue nil }.to_not change { SubmissionReminder.count }
      end
    end
  end

end
