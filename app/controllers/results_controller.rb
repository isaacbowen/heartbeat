class ResultsController < ApplicationController

  before_action :authenticate_user!
  before_action :ensure_valid_result_start_date!, except: :index
  before_action :authorize_team!, unless: -> { current_user.admin? }

  helper_method :result_scope, :result_team

  def index
    redirect_to action: :show, start_date: default_result_start_date.strftime('%Y%m%d'), scope: result_scope
  end

  def show
    @result = Result.new(
      start_date: result_start_date,
      source: result_submissions,
    )

    @metric_results = Metric.active.ordered.map do |metric|
      Result.new(
        start_date: result_start_date,
        source: metric.submission_metrics.where(submission: result_submissions),
        meta: metric.attributes.with_indifferent_access,
      )
    end
  end


  protected

  def result_scope
    @result_scope ||= params[:scope].presence.try(:to_sym)
  end

  def result_submissions
    if result_scope == :me
      Submission.where(user: current_user)
    else
      if result_team
        Submission.where(user: result_team.members)
      else
        Submission.all
      end
    end
  end

  def result_team
    @result_team ||= Team.find_by_slug(result_scope) if result_scope
  end

  def default_result_start_date
    (Date.today - 3.days).at_beginning_of_week
  end

  def result_start_date
    @result_start_date ||= Date.strptime(params[:start_date], '%Y%m%d') if params[:start_date]
  end

  def authorize_team!
    if result_team and not result_team.members.include? current_user
      redirect_to scope: nil
    end
  end

  def ensure_valid_result_start_date!
    if result_start_date.at_beginning_of_week != result_start_date
      redirect_to action: :show, start_date: result_start_date.at_beginning_of_week.strftime('%Y%m%d')
    end
  end

end
