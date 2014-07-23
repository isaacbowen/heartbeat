class Admin::UsersController < Admin::BaseController

  def index
    @users = User.order('active desc, email asc')
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    @user.update_attributes! user_params

    flash.notice = 'Got it.'

    redirect_to action: :edit
  end


  # less resourceful things

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


  protected

  def user_params
    params.require(:user).permit(:name, :manager_user_id, :tags_as_string, :active, report_ids: [])
  end

end
