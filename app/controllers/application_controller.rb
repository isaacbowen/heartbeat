class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception


  protected

  def authenticate_user!
    redirect_to :login unless user_signed_in?
  end

end
