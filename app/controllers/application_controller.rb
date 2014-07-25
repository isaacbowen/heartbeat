class ApplicationController < ActionController::Base

  helper CacheHelper

  protect_from_forgery with: :exception


  protected

  def authenticate_user!
    unless user_signed_in?
      session['user_return_to'] = request.fullpath
      redirect_to :login
    end
  end

end
