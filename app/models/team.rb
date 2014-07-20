# == Schema Information
#
# Table name: teams
#
#  id              :uuid             not null, primary key
#  name            :text             not null
#  slug            :text             not null
#  manager_user_id :uuid
#  description     :text
#  private         :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#

class Team < ActiveRecord::Base

  has_and_belongs_to_many :users
  belongs_to :manager, class_name: 'User', foreign_key: :manager_user_id

  validates_presence_of :name
  validates_presence_of :slug

  before_validation :set_slug

  accepts_nested_attributes_for :users

  def members
    users | User.where(id: manager_user_id)
  end

  def size
    members.size
  end

  def public?
    not private?
  end


  protected

  def slug_collision?
    if persisted?
      self.class.where('id != ?', id).where(slug: slug).any?
    else
      self.class.where(slug: slug).any?
    end
  end

  def set_slug
    return true unless name.present?

    self.slug ||= name.downcase.gsub(/[^\w\d\s]/, '').gsub(/[^\w]+/, '-').gsub(/(^\-|\-$)/, '')

    if slug_collision?
      slug_prefix = slug
      n = 1

      until Team.find_by_slug(slug).nil? do
        n = n + 1
        self.slug = "#{slug_prefix}-#{n}"
      end
    end
  end

end
