class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  helper_method :current_teams


  protected

  def current_teams
    if user_signed_in?
      @current_teams ||= (current_user.teams.select(&:public?) + current_user.managed_teams).uniq.sort_by(&:size)
    end
  end

  def authenticate_user!
    unless user_signed_in?
      session['user_return_to'] = request.fullpath
      redirect_to :login
    end
  end

end
