class UserMailer < ActionMailer::Base

  def submission_created user, submission
    @user = user
    @submission = submission

    mail to: user.email, subject: 'Invitation to Heartbeat'
  end

end
