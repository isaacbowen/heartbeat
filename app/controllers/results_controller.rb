class ResultsController < ApplicationController

  before_action :authenticate_user!

  def index
    start_date = (Date.today - 3.days).at_beginning_of_week

    scope = params[:scope].presence.try(&:to_sym) || :all

    redirect_to action: :show, id: start_date.strftime('%Y%m%d'), scope: scope
  end

  def show
    period = 1.week
    start_date = Date.strptime(params[:id], '%Y%m%d')

    if start_date.at_beginning_of_week != start_date
      redirect_to action: :show, id: start_date.at_beginning_of_week.strftime('%Y%m%d')
      return
    end

    @scope = params[:scope].presence.try(:to_sym) || :all

    submissions = begin
      case @scope
      when :me
        Submission.where(user: current_user)
      when :team
        if current_user.manager?
          Submission.where(user: current_user.team)
        else
          Submission.all
        end
      else
        Submission.all
      end
    end

    @result = Result.new(
      start_date: start_date,
      period: period,
      source: submissions,
    )

    @metric_results = Metric.active.ordered.map do |metric|
      Result.new(
        start_date: start_date,
        period: period,
        source: metric.submission_metrics.where(submission: submissions),
        meta: metric.attributes.with_indifferent_access,
      )
    end
  end

end
