class SubmissionReminderMailer < ActionMailer::Base

  def reminder submission_reminder
    @submission_reminder = submission_reminder

    mail to: submission_reminder.to, subject: submission_reminder.subject, from: submission_reminder.from
  end

end
