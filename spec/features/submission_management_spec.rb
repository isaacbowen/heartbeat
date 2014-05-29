require 'spec_helper'

feature 'Submission management' do

  before(:each) do
    page.driver.headers = {'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(ENV['HEARTBEAT_ADMIN_USERNAME'], ENV['HEARTBEAT_ADMIN_PASSWORD'])}
  end

  scenario 'Create submissions for all users' do
    create_list :metric, 5
    create_list :user, 50

    visit '/admin/submissions'

    User.all.each do |user|
      UserMailer.should_receive :submission_created do |submission|
        submission.user.should == user
        double.tap { |mail| mail.should_receive :deliver }
      end
    end

    click_button 'Request from all users'

    Submission.count.should == 50
    Submission.pluck(:user_id).uniq.size.should == 50

    page.should have_text '50 submission request(s) sent'
  end

end
