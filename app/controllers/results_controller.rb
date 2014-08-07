class ResultsController < ApplicationController

  before_action :authenticate_user!
  before_action :ensure_valid_result_start_date!, only: :show

  helper_method :result_scope, :scope_tags, :render_uncached_result?

  layout :result_layout

  def index
    start_date = default_result_start_date.strftime('%Y%m%d')

    case result_scope
    when :tags
      redirect_to [:tag, :result, start_date: start_date, tags: scope_tags.join(',')]
    when :all
      redirect_to [:result, start_date: start_date]
    else
      redirect_to [:scope, :result, start_date: start_date, scope: result_scope]
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
        eager: true,
      )
    end
  end


  # eh

  def index_tags
    redirect_to [:scope, :result, scope: :tags, start_date: default_result_start_date.strftime('%Y%m%d')]
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
      if params[:scope].present?
        params[:scope].to_sym
      elsif params[:tags].present?
        :tags
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
      when :tags
        if scope_tags.any?
          Submission.tagged_with(scope_tags)
        else
          Submission.all
        end
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

  def scope_tags
    params[:tags].try(:split, ',') || []
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

  def render_uncached_result?
    request.xhr?
  end

  # hack: let us generate and cache the content when requested over xhr, that
  # we might show our users a loading spinner whilst that's happening
  def result_layout
    if request.xhr?
      false
    else
      nil # use default layout
    end
  end

end