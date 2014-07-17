require 'spec_helper'

feature 'Admin authentication' do

  scenario 'Authenticated' do
    user = create :admin_user
    login_as user, scope: :user

    visit '/admin'

    page.status_code.should == 200
    page.current_path.should == '/admin'
  end

  scenario 'Unauthenticated' do
    user = create :user
    login_as user, scope: :user

    visit '/admin'

    page.status_code.should == 200
    page.should have_content 'Nope.'
    page.current_path.should == '/'
  end

end
