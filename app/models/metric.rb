# == Schema Information
#
# Table name: metrics
#
#  id          :uuid             not null, primary key
#  name        :text             not null
#  description :text             not null
#  order       :integer
#  active      :boolean          default(TRUE), not null
#  required    :boolean          default(FALSE), not null
#  created_at  :datetime
#  updated_at  :datetime
#

class Metric < ActiveRecord::Base

  has_many :submission_metrics, dependent: :restrict_with_exception
  has_many :submissions, through: :submission_metrics

  scope :active,   -> { where(active: true) }
  scope :required, -> { where(required: true) }
  scope :ordered,  -> { order('"order" asc') }

  def slug
    @slug ||= name.downcase.gsub(/[^\w]+/, '-')
  end

end
