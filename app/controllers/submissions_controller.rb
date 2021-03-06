class SubmissionsController < ApplicationController

  helper_method :current_submission
  before_action :authenticate_user!, only: :mine

  def mine
    submission = current_user.submissions.order('created_at desc').first

    if submission
      redirect_to submission
    else
      redirect_to :login
    end
  end

  def show
    redirect_to action: :edit unless current_submission.completed?
  end

  def edit
    if current_submission.closed?
      redirect_to action: :show
    end
  end

  def update
    begin
      current_submission.update_attributes! submission_params
    rescue ActionController::ParameterMissing
      # fail out silently. something in user_submits_submission_spec is
      # hitting this an extra time without any params. have not found it yet.
    end

    if request.xhr?
      render nothing: true, status: :ok
    else
      if current_submission.completed?
        redirect_to current_submission
      else
        redirect_to({action: :edit}, {notice: "Double-check your submission - make sure to fill in at least the first #{current_submission.metrics.required.size} metrics."})
      end
    end
  end


  protected

  def current_user
    super || current_submission.try(:user)
  end

  def current_submission
    Submission.find params[:id] if params[:id].present?
  end

  def submission_params
    params.require(:submission).permit(:tags_as_string, :comments, :comments_public,
                                       submission_metrics_attributes: [:id, :rating, :comments, :comments_public])
  end

end
