namespace :submissions do
  task :cron => [:reify_reminder_templates, :send_reminders]

  task :reify_reminder_templates => [:environment] do
    templates = SubmissionReminderTemplate.reify_pending!

    puts "Reified #{templates.size} template(s)"
  end

  task :send_reminders => [:environment] do
    reminders = SubmissionReminder.send_pending!

    puts "Sent #{reminders.size} reminder(s)"
  end
end
