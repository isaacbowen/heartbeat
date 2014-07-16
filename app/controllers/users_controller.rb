class UsersController < ApplicationController

  before_action :authenticate_user!, except: :index

  def show
    @submissions = current_user.submissions.order('created_at desc')
  end

end
