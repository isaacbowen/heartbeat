class MetaController < ApplicationController

  def root
  end

  def hit_me
    if Rails.env.development?
      redirect_to [:edit, User.where(email: params[:user][:email]).first_or_create.submissions.create]
    else
      redirect_to :root
    end
  end

end
