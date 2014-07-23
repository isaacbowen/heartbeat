require 'spec_helper'

feature 'The basics' do

  context 'guest' do
    %w(/ /about).each do |path|
      scenario "Visiting #{path}" do
        visit path
        page.status_code.should == 200
      end
    end
  end

  context 'user' do
    before(:each) { login_as create(:user), scope: :user }

    %w(/ /about /me /results).each do |path|
      scenario "Visiting #{path}" do
        visit path
        page.status_code.should == 200
      end
    end
  end

  context 'admin' do
    before(:each) { login_as create(:admin_user), scope: :user }

    %w(/admin /admin/users /admin/results).each do |path|
      scenario "Visiting #{path}" do
        visit path
        page.status_code.should == 200
      end
    end
  end

end
