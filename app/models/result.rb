class Result
  include ActiveModel::Model
  include CacheConcern

  MINIMUM_REPRESENTATION = 0.5 # %
  MINIMUM_SIZE = 2
  SPARKLINE_MAX_LENGTH = 12

  # e.g. 1.week
  attr_accessor :period

  # e.g. last monday
  attr_accessor :start_date

  # enumerable of items implementing #rating and #user and #comments
  attr_accessor :source

  # any other crap you want to throw in here
  attr_accessor :meta


  def sample options = {}
    @samples ||= Hash.new do |hash, options|
      sample_start_time = options[:start_time] || start_time
      sample_end_time   = options[:end_time] || end_time

      hash[options] = source.joins(:user).where("#{source.klass.table_name}.created_at >= ?", sample_start_time).where("#{source.klass.table_name}.created_at <= ?", sample_end_time)
    end

    @samples[options]
  end

  def sample_count
    sample.count
  end

  def completed_sample_count
    sample.complete.count
  end

  def period
    @period ||= 1.week
  end

  def complete?
    representation >= MINIMUM_REPRESENTATION
  end

  def incomplete?
    not complete?
  end

  def sufficient?
    size >= MINIMUM_SIZE
  end

  def insufficient?
    not sufficient?
  end

  def persisted?
    true
  end

  def to_key
    [start_date.strftime('%Y%m%d')]
  end

  def cache_key
    @cache_key ||= begin
      sample_digest, sample_updated_at = begin
        sample.group('1=1').pluck("encode(digest(string_agg(#{klass.table_name}.id::text, ','), 'md5'), 'hex'), max(#{klass.table_name}.updated_at)")[0]
      end

      "result/#{klass.name.underscore}/#{sample_digest}/#{sample_updated_at.to_i}"
    end
  end

  def reset_cache_key
    @cache_key = nil
  end

  def updated_at
    @updated_at ||= sample.maximum(:updated_at)
  end

  def created_at
    @created_at ||= sample.minimum(:created_at)
  end

  delegate :empty?, :any?, :count, :size, to: :sample
  delegate :klass, to: :source

  cache_attribute :sample_count, :completed_sample_count, :complete?, :size, :count, :empty?, :any?


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
    return unless klass.column_names.include? 'rating'
    
    sample.complete.average(:rating).try(:round, 1)
  end

  cache_attribute :rating


  def rating_counts
    return unless klass.column_names.include? 'rating'

    grouped_counts = sample.complete.group(:rating).count

    # represent the zero counts
    Hash[Heartbeat::VALID_RATINGS.map { |r| [r, 0] }].merge(grouped_counts)
  end

  cache_attribute :rating_counts


  def delta
    if previous.present?
      (rating - previous.rating).round(1)
    else
      0.0
    end
  end

  cache_attribute :delta


  def sparklines
    Hash[[:delta, :representation, :volatility, :unity].map { |thing|
      [thing, (0..SPARKLINE_MAX_LENGTH).map { |n| previous(n) }.reject(&:nil?).map(&thing).reverse]
    }]
  end

  cache_attribute :sparklines


  def representation
    sample.complete.count.to_f / sample.count
  end

  cache_attribute :representation


  def volatility
    return unless klass.column_names.include? 'rating'

    # use data from the current period and the previous period
    sample_plus_previous_period = sample(start_time: start_time - period)

    # pull out the standard deviation for ratings, by user
    stddev_ratings = sample_plus_previous_period.select('stddev_samp(rating) as stddev_rating').group('user_id').map(&:stddev_rating)

    # average the non-nils to get our volatility score
    stddev_ratings.reject(&:nil?).mean.round(1).to_f rescue 0.0
  end

  cache_attribute :volatility


  def unity
    return unless klass.column_names.include? 'rating'

    # unity = 1 - variance(ratings) / variance(max_rating, min_rating)
    maximum_variance = [Heartbeat::VALID_RATINGS.min, Heartbeat::VALID_RATINGS.max].variance

    unity_ratings = sample.complete.select("1.0 - var_samp(rating) / #{maximum_variance} as unity").group('users.manager_user_id').map(&:unity)

    # average the non-nils to get our volatility score
    unity_ratings.reject(&:nil?).mean.round(2) rescue 0.0
  end

  cache_attribute :unity


  # comments

  def comments
    sample.select { |s| s.comments.present? }.sort_by { |s| s.rating.to_f * -1 }.map { |s| Comment.new source: s }
  end

  def public_comments
    comments.select(&:public?)
  end

  def private_comments
    comments.reject(&:public?)
  end


  # pagination, sort of

  def previous n = 1
    return self if n == 0

    @previous_results ||= Hash.new do |hash, key|
      hash[key] = self.class.new(source: source, period: period, start_date: start_date - (key * period).seconds)
    end

    @previous_results[n].presence
  end

  def next n = 1
    return self if n == 0

    @next_results ||= Hash.new do |hash, key|
      hash[key] = self.class.new(source: source, period: period, start_date: start_date + (key * period).seconds)
    end

    @next_results[n].presence
  end

end
