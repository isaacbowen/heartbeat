class ApplicationController < ActionController::Base

  helper CacheHelper

  protect_from_forgery with: :exception
  before_filter :set_query_trace


  protected

  def authenticate_user!
    unless user_signed_in?
      session['user_return_to'] = request.fullpath
      redirect_to :login
    end
  end

  def set_query_trace
    if Rails.env.development?
      if params[:query_trace].present?
        ActiveRecordQueryTrace.enabled = true
        ActiveRecordQueryTrace.level   = :app
      else
        ActiveRecordQueryTrace.enabled = false
      end
    end
  end

end
