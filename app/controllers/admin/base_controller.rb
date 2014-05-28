class Admin::BaseController < ApplicationController

  before_action :authenticate

  protected

  def authenticate
    authenticate_or_request_with_http_basic 'Heartbeat' do |given_username, given_password|
      given_username == admin_username and given_password == admin_password
    end
  end

  def admin_username
    ENV['HEARTBEAT_ADMIN_USERNAME'] or raise 'Missing environment var HEARTBEAT_ADMIN_USERNAME!'
  end

  def admin_password
    ENV['HEARTBEAT_ADMIN_PASSWORD'] or raise 'Missing environment var HEARTBEAT_ADMIN_PASSWORD!'
  end

end
