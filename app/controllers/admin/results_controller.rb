class Admin::ResultsController < Admin::BaseController

  def index
    result = Result.new source: Submission.all
    @results = [result]

    while previous_result = @results.last.previous
      @results << previous_result
    end
  end

  def show
    period = 1.week
    start_date = Date.strptime(params[:id], '%Y%m%d')

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
