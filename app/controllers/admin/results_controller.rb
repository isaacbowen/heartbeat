class Admin::ResultsController < Admin::BaseController

  def index
    result = Result.new source: Submission.all
    @results = [result]

    while previous_result = @results.last.previous
      @results << previous_result
    end
  end

  def show
    @result = Result.new source: Submission.all, start_date: Date.strptime(params[:id], '%Y%m%d')
  end

end
