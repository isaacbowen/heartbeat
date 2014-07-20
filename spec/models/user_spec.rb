# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  name            :text
#  email           :text             not null
#  manager_user_id :uuid
#  manager_email   :text
#  created_at      :datetime
#  updated_at      :datetime
#  admin           :boolean          default(FALSE), not null
#  active          :boolean          default(TRUE), not null
#  team_id         :uuid
#

require 'spec_helper'

describe User do

  subject { create :user }

  describe '::find_for_google_oauth2' do
    let(:access_token) { double('access_token', info: info) }

    context 'the right domain' do
      let(:info) { {'email' => "foo@#{ENV['GOOGLE_APPS_DOMAIN']}", 'name' => 'Foo Bar'} }

      context 'new user' do
        it 'should give me back a persisted user' do
          user = User.find_for_google_oauth2(access_token)
          user.should be_persisted
          user.name.should  == 'Foo Bar'
          user.email.should == "foo@#{ENV['GOOGLE_APPS_DOMAIN']}"
          user.should_not be_active
        end
      end

      context 'existing user' do
        let(:user) { create :user, email: info['email'] }

        it 'should give me back the existing user' do
          user.should == User.find_for_google_oauth2(access_token)
        end
      end
    end

    context 'the wrong domain' do
      let(:info) { {'email' => "foo@rabble#{ENV['GOOGLE_APPS_DOMAIN']}", 'name' => 'Foo Bar'} }

      it 'should give me back an unpersisted user' do
        user = User.find_for_google_oauth2(access_token)
        user.should_not be_persisted
      end
    end
  end

  describe '#abbreviated_name' do
    specify { build(:user, name: 'Foo Bar').abbreviated_name.should == 'Foo B' }
    specify { build(:user, name: 'Foo Bar Zab').abbreviated_name.should == 'Foo B' }
    specify { build(:user, name: 'Foobar').abbreviated_name.should == 'Foobar' }
    specify { build(:user, name: nil).abbreviated_name.should be_nil }
  end

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

  describe '#to_liquid' do
    subject { build :user, name: 'Foo Bar', email: 'foo@bar.com' }

    specify do
      subject.to_liquid.should == {
        'name' => 'Foo Bar',
        'first_name' => 'Foo',
        'email' => 'foo@bar.com',
      }
    end
  end

end
