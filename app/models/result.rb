class Result
  include ActiveModel::Model

  # e.g. 1.week
  attr_accessor :period

  # e.g. last monday
  attr_accessor :start_date

  # enumerable of items implementing #rating and #user and #comments
  attr_accessor :source

  # any other crap you want to throw in here
  attr_accessor :meta

  def sample
    source.where('created_at >= ?', start_time).where('created_at <= ?', end_time)
  end

  def persisted?
    true
  end

  def to_key
    [start_date.strftime('%Y%m%d')]
  end

  delegate :empty?, :any?, :count, :size, :klass, to: :sample


  # date stuff

  def start_time
    start_date.at_beginning_of_day
  end

  def end_date
    start_date + period
  end

  def end_time
    end_date.at_end_of_day
  end


  # stats

  def rating
    ratings = sample.select(&:completed?).map(&:rating)
    (ratings.sum.to_f / ratings.size).round(1)
  end

  def rating_counts
    raise NotImplementedError unless klass.column_names.include?('rating')

    @rating_counts ||= begin
      grouped_counts = sample.complete.group(:rating).count

      # represent the zero counts
      Hash[Heartbeat::VALID_RATINGS.map { |r| [r, 0] }].merge(grouped_counts)
    end
  end

  def delta
    if previous.present?
      (rating - previous.rating).round(1)
    else
      0.0
    end
  end

  def representation
    sample.complete.count.to_f / sample.count
  end

  def shortest_time_to_completion
    sample.complete.select('min(completed_at - created_at) as completion_time')[0][:completion_time].try(:gsub, /^(\d+):(\d+):(\d+)\..*$/, '\1h \2m \3s')
  end


  # comments

  def comments
    sample.select { |s| s.comments.present? }.map { |s| Comment.new source: s }
  end

  def public_comments
    comments.select(&:public?)
  end


  # pagination, sort of

  def previous
    @previous ||= self.class.new(source: source, period: period, start_date: start_date - period)
    @previous if @previous.present?
  end

  def next
    @next ||= self.class.new(source: source, period: period, start_date: start_date + period)
    @next if @next.present?
  end

end
