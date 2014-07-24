class ResultsController < ApplicationController

  before_action :authenticate_user!
  before_action :ensure_valid_result_start_date!, only: :show

  helper_method :result_scope, :result_tag, :render_result?

  layout :result_layout

  def index
    start_date = default_result_start_date.strftime('%Y%m%d')

    if result_scope == :tag
      redirect_to [:tag, :result, start_date: start_date, tag: result_tag]
    else
      redirect_to [:result, start_date: start_date, scope: result_scope]
    end
  end

  def show
    @result = Result.new(
      start_date: result_start_date,
      source: result_submissions,
    )

    metrics = Metric.where(id: SubmissionMetric.where(submission: @result.sample).distinct(:metric_id).pluck(:metric_id)).ordered

    @metric_results = metrics.map do |metric|
      Result.new(
        start_date: result_start_date,
        source: metric.submission_metrics.where(submission: result_submissions),
        meta: metric.attributes.with_indifferent_access,
      )
    end
  end


  # eh

  def index_tags
    redirect_to [:tags, :result, start_date: default_result_start_date.strftime('%Y%m%d')]
  end

  def tags
    @result = Result.new(
      start_date: result_start_date,
      source: result_submissions,
    )

    @tags_and_counts = @result.sample.tags_and_counts
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
    @result_submissions ||= begin
      case result_scope
      when :me
        Submission.where(user: current_user)
      when :tag
        Submission.tagged_with(result_tag)
      when :managers, :reports, :vertical
        # reifying the user list here to reduce complexity down the line.
        # activerecord was generating invalid statements.
        Submission.where(user: current_user.send(result_scope).map(&:id))
      when :all
        Submission.all
      else
        Submission.none
      end
    end
  end

  def result_tags
    @result_tags ||= result_submissions.tags
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

  def render_result?
    request.xhr?
  end

  def result_layout
    if request.xhr?
      false
    else
      nil # use default layout
    end
  end

end