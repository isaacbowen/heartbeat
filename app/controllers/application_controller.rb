class ApplicationController < ActionController::Base

  helper CacheHelper

  protect_from_forgery with: :exception

  if Rails.env.development?
    before_filter :set_query_trace
    before_filter :clear_cache
  end


  protected

  def authenticate_user!
    unless user_signed_in?
      session['user_return_to'] = request.fullpath
      redirect_to :login
    end
  end

  def set_query_trace
    if params[:query_trace].present?
      ActiveRecordQueryTrace.enabled = true
      ActiveRecordQueryTrace.level   = :app
    else
      ActiveRecordQueryTrace.enabled = false
    end
  end

  def clear_cache
    Rails.cache.clear
  end

end
