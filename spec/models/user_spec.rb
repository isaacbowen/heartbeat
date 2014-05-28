require 'spec_helper'

describe User do

  subject { create :user }

  describe '#set_manager' do
    let(:manager) { @manager ||= create :user }

    it 'should create the manager relationship' do
      subject.manager_email = manager.email
      subject.send :set_manager
      subject.manager.should == manager
    end

    context 'in the absence of said manager' do
      it 'should do nothing' do
        subject.manager_email = Faker::Internet.email
        subject.send :set_manager
        subject.manager.should be_nil
      end
    end

    it 'should be invoked around save time' do
      subject.should_receive(:set_manager).and_call_original
      subject.manager_email = manager.email
      subject.save!

      subject.should_not be_changed
      subject.manager.should == manager
    end
  end

end
