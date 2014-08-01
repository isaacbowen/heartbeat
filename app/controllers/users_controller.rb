class UsersController < ApplicationController

  before_action :authenticate_user!, except: :index

  def show
    @user = current_user
  end

  def update
    current_user.update_attributes! user_params
    flash.notice = 'Got your updates - thanks!'

    redirect_to action: :show
  end

  def edit
    @user = User.find(params[:id])
  end


  # less resourceful. split these into their own controllers if they grow more complex.

  def history
    @submissions = current_user.submissions.order('created_at desc')
  end


  protected

  def user_params
    params.require(:user).permit(:tags_as_string, reports_attributes: [:id, :tags_as_string, :active])
  end

end
