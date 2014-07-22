class ResultsController < ApplicationController

  before_action :authenticate_user!
  before_action :ensure_valid_result_start_date!, except: :index

  helper_method :result_scope, :result_tag

  def index
    start_date = default_result_start_date.strftime('%Y%m%d')

    if result_scope == :tag
      redirect_to [:tag, :result, start_date: start_date, tag: result_tag]
    else
      redirect_to [:result, scope: result_scope]
    end
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
    @result_scope ||= begin
      if params[:tag].present?
        :tag
      elsif params[:scope].present?
        params[:scope].to_sym
      else
        :all
      end
    end
  end

  def result_submissions
    case result_scope
    when :me
      Submission.where(user: current_user)
    when :tag
      Submission.tagged_with(result_tag)
    when :all
      Submission.all
    else
      Submission.none
    end
  end

  def result_tag
    params[:tag] if result_scope == :tag
  end

  def default_result_start_date
    (Date.today - 3.days).at_beginning_of_week
  end

  def result_start_date
    @result_start_date ||= Date.strptime(params[:start_date], '%Y%m%d') if params[:start_date]
  end

  def ensure_valid_result_start_date!
    if result_start_date.at_beginning_of_week != result_start_date
      redirect_to action: :show, start_date: result_start_date.at_beginning_of_week.strftime('%Y%m%d')
    end
  end

end