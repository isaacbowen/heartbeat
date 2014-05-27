# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  name            :text             not null
#  email           :text             not null
#  manager_user_id :uuid
#  manager_email   :text
#  admin           :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base

  has_many :submissions, dependent: :destroy
  belongs_to :manager_user, class_name: 'User'

  before_save :set_manager_user


  protected

  def set_manager_user
    if manager_email.present?
      self.manager_user = User.find_by_email(manager_email)
    end
  end

end
