class ResultsController < ApplicationController

  def index
    start_date = Date.today.at_end_of_week
    redirect_to action: :show, id: start_date.strftime('%Y%m%d')
  end

  def show
    end_date   = Date.strptime params[:id], '%Y%m%d'
    start_date = end_date.at_beginning_of_week
    start_time = start_date.at_midnight

    @result = Result.new start_time, :week

    if @result.end_date.to_s != end_date.to_s
      redirect_to action: :show, id: @result.end_date.strftime('%Y%m%d')
    end
  end

end
