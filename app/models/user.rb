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

end
