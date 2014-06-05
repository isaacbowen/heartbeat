# == Schema Information
#
# Table name: submissions
#
#  id         :uuid             not null, primary key
#  user_id    :uuid
#  comments   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Submission < ActiveRecord::Base

  belongs_to :user
  has_many :submission_metrics, dependent: :delete_all
  has_many :metrics, through: :submission_metrics

  accepts_nested_attributes_for :submission_metrics
  accepts_nested_attributes_for :user, update_only: true

  validates_presence_of :user

  before_save :set_complete

  def seed_metrics
    return if self.submission_metrics.any?

    self.submission_metrics = Metric.active.map do |metric|
      SubmissionMetric.new metric: metric
    end
  end

  protected

  def set_complete
    self.completed = submission_metrics.required.all? &:complete?
    self.completed_at = Time.zone.now
  end

end
