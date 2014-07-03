class Admin::SubmissionReminderTemplatesController < Admin::BaseController

  def index
    @templates = SubmissionReminderTemplate.all
    @new_template = SubmissionReminderTemplate.new(
      submissions_start_date: Date.today.at_beginning_of_week,
      submissions_end_date: Date.today.at_end_of_week,
      medium: 'email',
      subject: 'Heartbeat time: week of 2014/06/30',
      from: 'Isaac Bowen <ibowen@enova.com>',
      template: "Hey {{user.first_name}},\n\nasdfasdfasdf\n\nYour submission for this week:\n{{submission.url}}\n\nLast week\'s results:\nhttp://enova.heartbeat.im/results/20140623\n\nCheers!\n\n--\nIsaac Bowen",
      reify_at: Time.zone.now,
    )
  end

  def create
    template = SubmissionReminderTemplate.create! submission_reminder_template_params

    redirect_to action: :index
  end


  protected

  def submission_reminder_template_params
    params.require(:submission_reminder_template).permit(:medium, :subject, :from, :template, :submissions_start_date, :submissions_end_date, :medium, :reify_at)
  end

end
