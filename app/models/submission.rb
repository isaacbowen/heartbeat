# == Schema Information
#
# Table name: submissions
#
#  id         :uuid             not null, primary key
#  user_id    :uuid
#  created_at :datetime
#  updated_at :datetime
#

class Submission < ActiveRecord::Base

  belongs_to :user
  has_many :submission_metrics, dependent: :delete_all

end
