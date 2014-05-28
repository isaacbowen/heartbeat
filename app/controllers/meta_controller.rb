class MetaController < ApplicationController

  def root
  end

  def hit_me
    if params[:user][:email] =~ /@enova\.com$/
      submission = User.where(email: params[:user][:email]).first_or_create.submissions.create

      if Rails.env.production?
        UserMailer.submission_created(submission).deliver
        redirect_to :root
      else
        redirect_to submission
      end
    else
      redirect_to :root
    end
  end

end
