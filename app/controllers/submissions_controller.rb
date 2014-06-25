class SubmissionsController < ApplicationController

  helper_method :current_submission

  def show
    if not current_submission.completed?
      redirect_to action: :edit
    end
  end

  def edit
    if current_submission.closed?
      redirect_to action: :show
    end
  end

  def update
    current_submission.update_attributes! submission_params

    redirect_to current_submission
  end


  protected

  def current_submission
    Submission.find params[:id]
  end

  def current_user
    current_submission.user
  end

  def submission_params
    params.require(:submission).permit(:comments, :comments_public,
                                       submission_metrics_attributes: [:id, :rating, :comments, :comments_public],
                                       user_attributes: [:name, :manager_email])
  end

end
