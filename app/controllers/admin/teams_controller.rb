class Admin::TeamsController < Admin::BaseController

  def index
    @teams = Team.all.order('slug asc')
    @team  = Team.new
  end

  def create
    Team.create! team_params
    redirect_to action: :index
  end

  def show
    redirect_to action: :edit
  end

  def edit
    @team = Team.find params[:id]
  end

  def update
    @team = Team.find params[:id]
    @team.update_attributes! team_params

    flash.notice = "#{@team.name} updated, woot."
    redirect_to action: :index
  end

  def destroy
    @team = Team.find params[:id]
    @team.destroy

    flash.notice = "#{@team.name} destroyed. Bum bum bummm."

    redirect_to action: :index
  end


  protected

  def team_params
    params.require(:team).permit(:name, :slug, :description, :manager_user_id, :parent_team_id, user_ids: [])
  end

end
