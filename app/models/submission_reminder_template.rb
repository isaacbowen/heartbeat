# == Schema Information
#
# Table name: submission_reminder_templates
#
#  id                     :uuid             not null, primary key
#  submissions_start_date :date             not null
#  submissions_end_date   :date             not null
#  reify_at               :datetime
#  reified                :boolean          default(FALSE), not null
#  medium                 :text             not null
#  template               :text             not null
#  meta                   :hstore
#

class SubmissionReminderTemplate < ActiveRecord::Base

  class << self
    def reify_pending!
      pending.to_a.tap { |p| p.each &:reify! }
    end
  end

  has_many :submission_reminders

  validates_presence_of :submissions_start_date
  validates_presence_of :submissions_end_date
  validates_presence_of :medium
  validates_presence_of :template

  store_accessor :meta, :subject, :from

  scope :reified,   -> { where(reified: true) }
  scope :unreified, -> { where(reified: false) }
  scope :pending,   -> { unreified.where('reify_at <= ?', Time.now) }

  def submissions
    Submission
      .where('created_at >= ?', submissions_start_date.at_beginning_of_day)
      .where('created_at <= ?', submissions_end_date.at_end_of_day)
  end

  def reify!
    transaction do
      submission_reminders = submissions.incomplete.map do |submission|
        submission.submission_reminders.where(submission_reminder_template: self).first_or_create! do |submission_reminder|
          submission_reminder.submission_reminder_template = self
          %w(subject from medium template).each do |attr|
            submission_reminder.send "#{attr}=", send(attr)
          end
        end
      end

      self.reified = true

      save!

      submission_reminders
    end
  end

end
