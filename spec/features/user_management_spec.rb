require 'spec_helper'

feature 'User management' do

  before(:each) do
    user = create :admin_user
    login_as user, scope: :user
  end

  scenario 'Import users' do
    emails = (1..50).to_a.map { Faker::Internet.email }.sort

    # test omitting redundant emails
    emails.first(10).each do |email|
      create :user, email: email
    end

    visit '/admin/users/import'

    fill_in 'Emails', with: emails.join("\n")

    click_button 'Submit'

    page.should have_text '40 user(s) created'

    User.pluck(:email).sort.should == emails
  end

  scenario 'List users' do
    users = create_list :user, 5

    visit '/admin/users'

    users.each do |user|
      page.should have_text user.email
    end
  end

end
