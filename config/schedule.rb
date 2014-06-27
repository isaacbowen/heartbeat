every :thursday, at: '1pm' do
  # send initial emails
  runner 'SubmissionReminder::CreateWorker.perform_async(medium: "email")'
end

every :friday, at: '10am' do
  # send reminder emails
  runner 'SubmissionReminder::CreateWorker.perform_async(medium: "email")'
end

every :monday, at: '10am' do
  # send slack messages
  runner 'SubmissionReminder::CreateWorker.perform_async(medium: "slack")'
end
