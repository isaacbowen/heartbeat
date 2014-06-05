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

  scope :required,  -> { joins(:metric).where(metrics: {required: true}) }
  scope :completed, -> { where(completed: true) }

  belongs_to :submission
  belongs_to :metric

  validates_presence_of :submission
  validates_presence_of :metric

  before_save :set_completed

  delegate :name, :description, :required?, to: :metric

  include CompletedConcern
  completed_with -> { rating.present? }


  def rating= value
    if VALID_RATINGS.include? value.to_i
      self[:rating] = value.to_i
    end
  end

end
