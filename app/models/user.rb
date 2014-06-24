# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  name            :text
#  email           :text             not null
#  manager_user_id :uuid
#  manager_email   :text
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base

  has_many :submissions, dependent: :destroy
  has_many :submission_metrics, through: :submissions
  belongs_to :manager, class_name: 'User', foreign_key: :manager_user_id

  before_save :set_manager

  def first_name
    name.split(/\s+/).first rescue name
  end


  protected

  def set_manager
    if manager_email.present?
      self.manager = User.find_by_email(manager_email)
    end
  end

end
