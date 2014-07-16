class Admin::BaseController < ApplicationController

  before_action :authenticate_user!
  before_action :authorize_user!


  protected

  def authorize_user!
    current_user.admin?
  end

end
