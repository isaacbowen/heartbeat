class ResultsController < ApplicationController

  def index
    start_date = Date.today.at_beginning_of_week
    redirect_to action: :show, id: start_date.strftime('%Y%m%d')
  end

  def show
    period = 1.week
    start_date = Date.strptime(params[:id], '%Y%m%d')

    if start_date.at_beginning_of_week != start_date
      redirect_to action: :show, id: start_date.at_beginning_of_week.strftime('%Y%m%d')
      return
    end

    @result = Result.new(
      start_date: start_date,
      period: period,
      source: Submission.all,
    )

    @metric_results = Metric.active.ordered.map do |metric|
      Result.new(
        start_date: start_date,
        period: period,
        source: metric.submission_metrics,
        meta: metric.attributes.with_indifferent_access,
      )
    end
  end

end
