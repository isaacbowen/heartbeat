require 'spec_helper'

feature 'Admin authentication' do

  let(:expected_username) { 'foo' }
  let(:expected_password) { 'baz' }

  def give_credentials username, password
    page.driver.headers = {'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(username, password)}
  end

  before(:each) do
    Admin::BaseController.any_instance.stub(:admin_username) { expected_username }
    Admin::BaseController.any_instance.stub(:admin_password) { expected_password }
  end

  after(:each) do
    page.driver.headers.delete('Authorization')
  end

  scenario 'Successful authentication' do
    give_credentials expected_username, expected_password

    visit '/admin'

    page.status_code.should == 200
  end

  scenario 'Failed authentication' do
    give_credentials 'baz', 'rabble'

    visit '/admin'

    page.status_code.should == 401
  end

end
