class Admin::SubmissionReminderTemplatesController < Admin::BaseController

  def index
    @templates = SubmissionReminderTemplate.all.order('reify_at desc')
    @new_template = SubmissionReminderTemplate.new(
      submissions_start_date: Date.today.at_beginning_of_week,
      submissions_end_date: Date.today.at_end_of_week,
      medium: 'email',
      subject: @templates.first.subject,
      from: @templates.first.from,
      template: @templates.first.template,
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
