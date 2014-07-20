# == Schema Information
#
# Table name: teams
#
#  id              :uuid             not null, primary key
#  name            :text             not null
#  slug            :text             not null
#  manager_user_id :uuid
#  description     :text
#  private         :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Team do
  
  describe '#slug' do
    it 'should autopopulate' do
      create(:team, name: 'Raven').slug.should == 'raven'
      create(:team, name: 'Foo Bar').slug.should == 'foo-bar'
      create(:team, name: '^Foo Bar???? 2??????Baz!').slug.should == 'foo-bar-2baz'
      create(:team, name: 'isaac\'s "safari" team').slug.should == 'isaacs-safari-team'
    end

    it 'should autoincrement to avoid dups' do
      create(:team, name: 'Raven').slug.should == 'raven'
      create(:team, name: 'Raven').slug.should == 'raven-2'
      create(:team, name: 'Raven').slug.should == 'raven-3'
    end

    it 'should retain slugs' do
      team = create(:team, name: 'Raven')
      team.name = 'asdf'
      team.save!
      team.slug.should == 'raven'
    end
  end

  describe '#members' do
    it 'should be the users plus the manager' do
      team = create :team, users: build_list(:user, 5), manager: build(:user)
      team.members.size.should == 6
    end
  end

  describe '#size' do
    it 'should delegate to #members' do
      team = create :team
      team.should_receive(:members) { double(size: 4) }
      team.size.should == 4
    end
  end

end
