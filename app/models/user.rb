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
  include TaggableConcern

  has_many :submissions, dependent: :destroy
  has_many :submission_metrics, through: :submissions

  belongs_to :manager, class_name: 'User', foreign_key: :manager_user_id
  has_many   :reports, class_name: 'User', foreign_key: :manager_user_id

  devise :omniauthable

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  class << self
    def find_for_google_oauth2 access_token, signed_in_resource = nil
      data = access_token.info

      user = User.find_or_initialize_by(email: data['email']) do |user|
        user.name   = data['name']
        user.active = false

        user.save! if user.email.to_s.ends_with? "@#{ENV['GOOGLE_APPS_DOMAIN']}"
      end

      # take this opportunity to update our records
      if user.persisted?
        user.name = data['name']

        user.save! if user.changed?
      end

      user
    end
  end

  def abbreviated_name
    return name if name.blank?

    name_bits = name.split(/\s+/, 2)

    if name_bits.size == 1
      name
    else
      "#{name_bits[0]} #{name_bits[1][0]}"
    end
  end

  def first_name
    name.split(/\s+/).first rescue name
  end

  def to_liquid
    {
      'first_name' => first_name,
      'name' => name,
      'email' => email,
    }
  end

  def manager?
    reports.any?
  end

  def inactive?
    not active?
  end

end
