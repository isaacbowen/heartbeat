class SubmissionsController < ApplicationController

  helper_method :current_submission

  def show
  end

  def update
    current_submission.update_attributes! params.require(:submission).permit(:comments, submission_metrics_attributes: [:id, :rating, :comments])

    redirect_to current_submission
  end


  protected

  def current_submission
    Submission.find params[:id]
  end

  def current_user
    current_submission.user
  end

end
