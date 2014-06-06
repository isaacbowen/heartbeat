class UserMailer < ActionMailer::Base

  default from: 'ibowen@enova.com'

  def submission_created submission, subject = nil, message = nil
    @subject = subject.presence || 'Invitation to Heartbeat'
    @message = message.presence || 'We have a message for you!'
    @user = submission.user
    @submission = submission
    @domain = ENV['HEARTBEAT_DOMAIN']

    mail to: @user.email, subject: @subject, from: @from
  end

end
