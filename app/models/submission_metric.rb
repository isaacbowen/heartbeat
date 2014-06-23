# == Schema Information
#
# Table name: submission_metrics
#
#  id            :uuid             not null, primary key
#  submission_id :uuid
#  metric_id     :uuid
#  rating        :integer
#  comments      :text
#  completed     :boolean          default(FALSE), not null
#  completed_at  :datetime
#

class SubmissionMetric < ActiveRecord::Base

  scope :required,  -> { joins(:metric).where(metrics: {required: true}) }
  scope :optional,  -> { joins(:metric).where(metrics: {required: false}) }
  scope :completed, -> { where(completed: true) }
  scope :ordered,   -> { joins(:metric).order('metrics.order asc') }

  belongs_to :submission
  belongs_to :metric
  has_one :user, through: :submission

  validates_presence_of :submission
  validates_presence_of :metric

  before_save :set_completed

  delegate :name, :description, :required?, to: :metric

  include CompletedConcern
  completed_with -> { rating.present? }


  def rating= value
    if Heartbeat::VALID_RATINGS.include? value.to_i
      self[:rating] = value.to_i
    end
  end

  def previous
    submission.previous.try(:submission_metrics).try(:find_by_metric_id, metric_id)
  end

end
