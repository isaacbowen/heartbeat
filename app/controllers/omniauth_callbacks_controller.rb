class OmniauthCallbacksController < Devise::OmniauthCallbacksController   

  def google_oauth2 
    user = User.find_for_google_oauth2(request.env['omniauth.auth'], current_user)

    if user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect user, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth']
      redirect_to :root, notice: "Sorry, you must have an @#{ENV['GOOGLE_APPS_DOMAIN']} email address."
    end
  end

  protected

  # for devise's purposes, send folks back to the root
  def new_session_path *args
    root_path *args
  end

end
