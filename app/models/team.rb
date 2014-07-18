# == Schema Information
#
# Table name: teams
#
#  id              :uuid             not null, primary key
#  name            :text             not null
#  slug            :text             not null
#  parent_team_id  :uuid
#  manager_user_id :uuid
#  description     :text
#  active          :boolean          default(TRUE), not null
#  created_at      :datetime
#  updated_at      :datetime
#

class Team < ActiveRecord::Base

  has_and_belongs_to_many :users
  belongs_to :manager_user, class_name: 'User'
  belongs_to :parent_team
  has_many :teams, foreign_key: :parent_team_id

  validates_presence_of :name
  validates_presence_of :slug

  before_validation :set_slug

  accepts_nested_attributes_for :users, :teams

  def members
    users | User.where(id: manager_user_id)
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

    self.slug ||= name.downcase.gsub(/[^\w]+/, '-').gsub(/(^\-|\-$)/, '')

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
