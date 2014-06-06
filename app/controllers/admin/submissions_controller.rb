class Admin::SubmissionsController < Admin::BaseController

  def index
  end

  def batch
    User.all.each do |user|
      submission = user.submissions.create!
      UserMailer.submission_created(submission, params[:subject], params[:message], params[:from]).deliver
    end

    flash.notice = "#{User.count} submission request(s) sent"

    redirect_to action: :index
  end

end
