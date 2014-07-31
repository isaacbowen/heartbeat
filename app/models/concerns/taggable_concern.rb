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

  def tags
    self[:tags] || []
  end

  def tags= the_tags
    self[:tags] = the_tags

    clean_tags!
  end

  def suggested_tags
    if tags.size <= 1
      []
    else
      (self.class.tagged_with(*tags).tags_and_counts.to_a.map(&:first).map(&:to_s) - tags)
    end
  end


  protected

  def clean_tags!
    tags.map! { |tag| clean_tag(tag) }
    tags.uniq!
  end


  module ClassMethods
    def tagged_with *tags
      tags.inject(self) do |scope, tag|
        scope.where("? = ANY (\"#{table_name}\".\"tags\")", clean_tag(tag))
      end
    end

    def tags
      pluck(:tags).flatten.uniq.sort.reject(&:nil?).map(&:to_sym)
    end

    def tags_and_counts
      scope = self

      ActiveSupport::OrderedHash[scope.tags.map { |tag| [tag, scope.tagged_with(tag).count] }.sort_by { |t, c| [c*-1, t] }]
    end

    def untagged
      where(tags: '{}')
    end

    def tagged
      where.not(tags: '{}')
    end

    def clean_tag tag
      tag.to_s.gsub(/[^\w\-_]/, '')
    end
  end
end
