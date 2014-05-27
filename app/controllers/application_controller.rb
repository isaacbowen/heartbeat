class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  helper_method :current_user


  protected

  def current_user
  end

end
