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

  devise :omniauthable

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  class << self
    def find_for_google_oauth2 access_token, signed_in_resource = nil
      data = access_token.info

      User.find_or_initialize_by(email: data['email']) do |user|
        user.name = data['name']

        user.save! if user.email.to_s.ends_with? "@#{ENV['GOOGLE_APPS_DOMAIN']}"
      end
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
    User.where(manager_email: email).any?
  end

  def team
    if manager?
      User.where(manager_email: email)
    else
      User.where(manager_email: manager_email)
    end
  end


  protected

  def set_manager
    if manager_email.present?
      self.manager = User.find_by_email(manager_email)
    end
  end

end
