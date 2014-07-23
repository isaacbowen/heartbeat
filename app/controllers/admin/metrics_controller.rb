class Admin::MetricsController < Admin::BaseController

  def index
    @metrics = Metric.order('"active" desc, "order" asc').to_a
    @metrics << Metric.new
  end

  def update
    @metric = Metric.find params[:id]
    @metric.update_attributes! metric_params

    flash.notice = 'Got it.'

    redirect_to action: :index
  end

  def create
    @metric = Metric.create! metric_params

    flash.notice = "Created #{@metric.name}."

    redirect_to action: :index
  end

  def destroy
    @metric = Metric.find params[:id]
    @metric.destroy

    flash.notice = "Destroyed #{@metric.name}."

    redirect_to action: :index
  end


  protected

  def metric_params
    params.require(:metric).permit(:name, :slug, :description, :required, :order, :active)
  end

end
