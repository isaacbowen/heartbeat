class UserMailer < ActionMailer::Base

  default from: 'ibowen@enova.com'

  def submission_created submission
    @user = submission.user
    @submission = submission

    mail to: @user.email, subject: 'Invitation to Heartbeat'
  end

end
