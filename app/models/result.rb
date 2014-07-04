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

  def sample options = {}
    sample_start_time = options[:start_time] || start_time
    sample_end_time   = options[:end_time] || end_time

    source.where("#{source.klass.table_name}.created_at >= ?", sample_start_time).where("#{source.klass.table_name}.created_at <= ?", sample_end_time)
  end

  def period
    @period ||= 1.week
  end

  def complete?
    representation > 0.5
  end

  def persisted?
    true
  end

  def to_key
    [start_date.strftime('%Y%m%d')]
  end

  def cache_key
    @cache_key ||= begin
      digest = Digest::MD5.hexdigest(sample.pluck(:id).join)
      "result/#{klass.name.underscore}/#{digest}/#{updated_at.to_i}"
    end
  end

  def updated_at
    @updated_at ||= sample.maximum(:updated_at)
  end

  def created_at
    @created_at ||= sample.minimum(:created_at)
  end

  delegate :empty?, :any?, :count, :size, :klass, to: :sample


  # date stuff

  def start_date
    @start_date ||= Date.current.at_beginning_of_week
  end

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
    sample.select(&:completed?).map(&:rating).mean.round(1)
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

  def sparklines
    @sparklines ||= Hash.new do |hash, key|
      hash[key] = (0..5).map { |n| previous(n) }.reject(&:nil?).map { |r| [r.start_date, r.send(key)] }
    end
  end

  def representation
    @representation ||= begin
      sample.complete.count.to_f / sample.count
    end
  end

  def volatility
    raise NotImplementedError unless klass.column_names.include?('rating')

    @volatility ||= begin
      # use data from the current period and the previous period
      sample_plus_previous_period = sample(start_time: start_time - period)

      # pull out the standard deviation for ratings, by user
      stddev_ratings = sample_plus_previous_period.joins(:user).select('stddev_samp(rating) as stddev_rating').group(:user_id).map(&:stddev_rating)

      # average the non-nils to get our volatility score
      stddev_ratings.reject(&:nil?).mean.round(1) rescue 0.0
    end
  end

  def unity
    raise NotImplementedError unless klass.column_names.include?('rating')

    @unity ||= begin
      # unity = 1 - variance(ratings) / variance(max_rating, min_rating)
      unity_ratings = sample.joins(:user).select("1.0 - var_samp(rating) / #{[Heartbeat::VALID_RATINGS.min, Heartbeat::VALID_RATINGS.max].variance} as unity").group('users.manager_email').map(&:unity)

      # average the non-nils to get our volatility score
      unity_ratings.reject(&:nil?).mean.round(2) rescue 0.0
    end
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

  def private_comments
    comments.reject(&:public?)
  end


  # pagination, sort of

  def previous n = 1
    @previous ||= Hash.new do |hash, key|
      hash[key] = self.class.new(source: source, period: period, start_date: start_date - (key * period).seconds)
    end

    @previous[n].presence
  end

  def next n = 1
    @next ||= Hash.new do |hash, key|
      hash[key] = self.class.new(source: source, period: period, start_date: start_date + (key * period).seconds)
    end

    @next[n].presence
  end

end
