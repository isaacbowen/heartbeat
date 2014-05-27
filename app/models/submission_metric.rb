# == Schema Information
#
# Table name: submission_metrics
#
#  id            :uuid             not null, primary key
#  submission_id :uuid
#  metric_id     :uuid
#  rating        :integer
#  comments      :text
#

class SubmissionMetric < ActiveRecord::Base

  belongs_to :submission
  belongs_to :metric

  delegate :name, :description, to: :metric

  def complete?
    rating.present?
  end

end
