# == Schema Information
#
# Table name: submission_reminders
#
#  id                              :uuid             not null, primary key
#  submission_id                   :uuid             not null
#  medium                          :text             not null
#  message                         :text
#  meta                            :hstore
#  sent                            :boolean          default(FALSE), not null
#  sent_at                         :datetime
#  created_at                      :datetime
#  updated_at                      :datetime
#  submission_reminder_template_id :uuid
#

require 'spec_helper'

describe SubmissionReminder do

  subject { build :submission_reminder }

  describe '::send_pending!' do
    it 'should sending pending things' do
      pending = create_list :submission_reminder, 5

      # eehhhh, mostly we just need to prevent the email from actually happening
      subject.class.any_instance.stub(:send_email!)

      subject.class.pending.should_not be_empty
      subject.class.send_pending!
      subject.class.pending.should be_empty
    end
  end

  describe '#to' do
    specify { subject.to.should == "#{subject.user.name} <#{subject.user.email}>" }
  end

  describe '#send!' do
    context 'no medium' do
      subject { build :submission_reminder, medium: '' }

      it 'should raise' do
        expect { subject.send! }.to raise_error StandardError
      end
    end

    context 'unknown medium' do
      subject { build :submission_reminder, medium: 'asdf' }

      it 'should raise' do
        expect { subject.send! }.to raise_error NotImplementedError
      end
    end

    context 'known medium' do
      subject { build :submission_reminder, medium: 'lala' }

      it 'should not raise, and should set :sent and :sent_at' do
        Timecop.freeze do
          subject.should_receive(:send_lala!) { 'some result' }
          subject.send!.should == 'some result'

          subject.should be_sent
          subject.sent_at.should == Time.now
        end
      end
    end
  end

  describe '#render_template' do
    it 'should render with liquid, with template options' do
      subject.should_receive(:template_options) { {'foo' => 'bar'} }
      subject.template = '{{ foo }}'
      subject.send(:render_template).should == 'bar'
    end
  end

  describe '#message' do
    it 'should default to calling #render_template' do
      subject.message = nil

      subject.should_receive(:render_template) { 'asdf' }

      subject.message.should == 'asdf'
    end

    it 'should be invalid if it\'s missing the sub url' do
      subject.medium = 'email'

      subject.message = 'asdf'
      subject.should_not be_valid

      subject.message = "hello #{subject.submission.url} there"
      subject.should be_valid
    end
  end

  describe '#template_options' do
    specify do
      subject.user.should be_a User
      subject.submission.should be_a Submission

      subject.send(:template_options).should == {
        'user' => subject.user,
        'submission' => subject.submission,
      }
    end
  end

end
