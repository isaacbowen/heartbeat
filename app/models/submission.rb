# == Schema Information
#
# Table name: submissions
#
#  id           :uuid             not null, primary key
#  user_id      :uuid
#  completed    :boolean          default(FALSE), not null
#  completed_at :datetime
#  comments     :string(140)
#  created_at   :datetime
#  updated_at   :datetime
#

class Submission < ActiveRecord::Base

  belongs_to :user
  has_many :submission_metrics, dependent: :delete_all
  has_many :metrics, through: :submission_metrics

  accepts_nested_attributes_for :submission_metrics
  accepts_nested_attributes_for :user, update_only: true

  validates_presence_of :user

  before_create :seed_metrics!


  include CompletedConcern

  completed_with -> {
    submission_metrics.present? and
    submission_metrics.any? &:completed? and

    # manually select through; we may be mid-save, so if we fetch from the db we'll get stale data
    submission_metrics.select(&:required?).all? &:completed?
  }


  def seed_metrics!
    return if self.submission_metrics.any?

    self.submission_metrics = Metric.active.map do |metric|
      SubmissionMetric.new metric: metric
    end
  end

end
