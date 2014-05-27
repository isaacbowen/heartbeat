# == Schema Information
#
# Table name: metrics
#
#  id          :uuid             not null, primary key
#  name        :text             not null
#  description :text             not null
#  order       :integer
#  active      :boolean          default(TRUE)
#  created_at  :datetime
#  updated_at  :datetime
#

class Metric < ActiveRecord::Base

  has_many :submission_metrics
  has_many :submissions, through: :submission_metrics

end
