class ResultsController < ApplicationController

  def index
    start_date = Date.today.at_beginning_of_week - 1.week
    redirect_to action: :show, id: start_date.strftime('%Y%m%d')
  end

  def show
    start_date = Date.strptime params[:id], '%Y%m%d'
    start_time = start_date.at_midnight

    @result = Result.new start_time, :week
  end

end
