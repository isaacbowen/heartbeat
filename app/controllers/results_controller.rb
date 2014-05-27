class ResultsController < ApplicationController

  def index
    start_date = Date.today.at_beginning_of_week - 1.week
    end_date   = start_date + 4.days
    redirect_to action: :show, start_date: start_date.strftime('%Y%m%d'), end_date: end_date.strftime('%Y%m%d')
  end

  def show
    start_date = Date.strptime params[:start_date], '%Y%m%d'
    start_time = start_date.at_midnight

    end_date = Date.strptime params[:end_date], '%Y%m%d'
    end_time = end_date.at_midnight + 1.day

    @result = Result.new start_time, end_time
  end

end
