class Admin::UsersController < Admin::BaseController

  def index
    @users = User.order('email asc')
  end

  def become
    @user = User.find params[:id]
    sign_in @user
    redirect_to :root
  end

  def import
    if params[:emails].present?
      original_user_count = User.count

      emails = params[:emails].split(/\s*,?\s+/).map(&:strip).reject(&:empty?)
      emails.each do |email|
        User.where(email: email).first_or_create!
      end

      user_delta = User.count - original_user_count

      flash.notice = "#{user_delta} user(s) created. Woot."

      redirect_to action: :index
    end
  end

end
