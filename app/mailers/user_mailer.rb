class UserMailer < ActionMailer::Base

  default from: 'ibowen@enova.com'

  def submission_created user, submission
    @user = user
    @submission = submission

    mail to: user.email, subject: 'Invitation to Heartbeat'
  end

end
