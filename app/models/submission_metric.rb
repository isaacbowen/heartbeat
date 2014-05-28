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

  VALID_RATINGS = [1, 2, 3, 4]

  belongs_to :submission
  belongs_to :metric

  validates_presence_of :submission
  validates_presence_of :metric

  delegate :name, :description, to: :metric

  def complete?
    rating.present?
  end

  def rating= value
    if VALID_RATINGS.include? value.to_i
      self[:rating] = value.to_i
    end
  end

end
