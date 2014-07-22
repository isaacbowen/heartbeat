module TaggableConcern
  extend ActiveSupport::Concern

  included do
    delegate :clean_tag, to: :class
  end

  def tags_as_string
    tags.map { |t| "##{t}" }.join(' ')
  end

  def tags_as_string= str
    self.tags = str.try :split, /\s+(?:,?\s+)?/
  end

  def tags= the_tags
    self[:tags] = the_tags

    clean_tags!
  end


  protected

  def clean_tags!
    tags.map! { |tag| clean_tag(tag) }
    tags.uniq!
  end


  module ClassMethods
    def tagged_with tag
      where('? = ANY (tags)', clean_tag(tag))
    end

    def untagged
      where("tags = '{}'")
    end

    def tagged
      where("tags != '{}'")
    end

    def clean_tag tag
      tag.to_s.gsub /[^\w\-_]/, ''
    end
  end
end
