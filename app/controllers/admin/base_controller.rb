class Admin::BaseController < ApplicationController

  before_action :authenticate_user!
  before_action :authorize_user!


  protected

  def authorize_user!
    unless current_user.admin?
      redirect_to :root, notice: 'Nope.'
    end
  end

end
