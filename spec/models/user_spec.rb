# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  name            :text
#  email           :text             not null
#  manager_user_id :uuid
#  created_at      :datetime
#  updated_at      :datetime
#  admin           :boolean          default(FALSE), not null
#  active          :boolean          default(TRUE), not null
#  tags            :string(255)      default([]), is an Array
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

  describe '#manager?' do
    specify { create(:user, reports: build_list(:user, 2)).should be_manager }
    specify { create(:user, reports: []).should_not be_manager }
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

  describe '#managers' do
    it 'should be the management chain, top to bottom' do
      dfish = create :user
      dhall = create :user, manager: dfish
      jjon  = create :user, manager: dhall
      me    = create :user, manager: jjon
      blake = create :user, manager: dhall

      me.managers.should == [dfish, dhall, jjon]
    end
  end

  describe '#vertical' do
    it 'should be #managers + me + #reports' do
      dfish = create :user
      dhall = create :user, manager: dhall
      jjon  = create :user, manager: jjon
      me    = create :user, manager: jjon
      trogdor = create_list :user, 5, manager: me

      blake = create :user, manager: dhall
      shodan = create_list :user, 5, manager: blake

      me.vertical.should == me.managers + [me] + me.reports
    end
  end

end
