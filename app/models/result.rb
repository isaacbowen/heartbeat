class Result
  include ActiveModel::Model

  MINIMUM_REPRESENTATION = 0.5 # %
  MINIMUM_SIZE = 2
  DEFAULT_MODE = :cached
  SPARKLINE_MAX_LENGTH = 12

  # e.g. 1.week
  attr_accessor :period

  # e.g. last monday
  attr_accessor :start_date

  # enumerable of items implementing #rating and #user and #comments
  attr_accessor :source

  # any other crap you want to throw in here
  attr_accessor :meta

  # :live (stats are run on the db) or :cached (stats are run in-memory)
  attr_accessor :mode

  def mode
    @mode ||= DEFAULT_MODE
  end

  def mode= value
    raise NotImplementedError unless [:live, :cached].include? value

    @mode = value
  end

  def live_mode?
    mode == :live
  end

  # reset everything except the attributes with accessors
  def reload
    instance_variables.each do |instance_variable|
      # skip if, for :@foo, the object responds to foo=
      next if respond_to?(instance_variable.to_s.gsub(/^@/, '') + '=')

      instance_variable_set instance_variable, nil
    end
  end

  def sample options = {}
    @samples ||= Hash.new do |hash, options|
      hash[options] = begin
        sample_start_time = options[:start_time] || start_time
        sample_end_time   = options[:end_time] || end_time

        scope = source.joins(:user).where("#{source.klass.table_name}.created_at >= ?", sample_start_time).where("#{source.klass.table_name}.created_at <= ?", sample_end_time)

        if live_mode?
          scope
        else
          scope.to_a
        end
      end
    end

    @samples[options]
  end

  def completed_sample
    @completed_sample ||= begin
      if live_mode?
        sample.complete
      else
        sample.select(&:completed?)
      end
    end
  end

  def sample_count
    @sample_count ||= sample.size
  end

  def completed_sample_count
    @completed_sample_count ||= completed_sample.size
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
      ids = if live_mode? then sample.pluck(:id) else sample.map(&:id) end
      digest = Digest::MD5.hexdigest(ids.join)
      "result/#{klass.name.underscore}/#{digest}/#{updated_at.to_i}"
    end
  end

  def updated_at
    @updated_at ||= begin
      if live_mode?
        sample.maximum(:updated_at)
      else
        sample.map(&:updated_at).max
      end
    end
  end

  def created_at
    @created_at ||= begin
      if live_mode?
        sample.minimum(:created_at)
      else
        sample.map(&:created_at).min
      end
    end
  end

  delegate :empty?, :any?, :count, :size, to: :sample
  delegate :klass, to: :source


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
      grouped_counts = begin
        if live_mode?
          sample.complete.group(:rating).count
        else
          completed_sample.map(&:rating).inject(Hash.new(0)) { |hash, value| hash[value] += 1; hash }
        end
      end

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
      hash[key] = (0..SPARKLINE_MAX_LENGTH).map { |n| previous(n) }.reject(&:nil?).map(&key).reverse
    end
  end

  def representation
    @representation ||= begin
      if live_mode?
        sample.complete.count.to_f / sample.count
      else
        completed_sample.size.to_f / sample.size
      end
    end
  end

  def volatility
    raise NotImplementedError unless klass.column_names.include?('rating')

    @volatility ||= begin
      # use data from the current period and the previous period
      sample_plus_previous_period = sample(start_time: start_time - period)

      # pull out the standard deviation for ratings, by user
      stddev_ratings = begin
        if live_mode?
          sample_plus_previous_period.select('stddev_pop(rating) as stddev_rating').group('user_id').map(&:stddev_rating)
        else
          users_and_ratings = sample_plus_previous_period.map { |s| [s.user.id, s.rating] }

          ratings_by_user = users_and_ratings.group_by(&:first).map { |user_id, pairs| pairs.map(&:last) }

          ratings_by_user.map do |ratings|
            if ratings.all? &:present?
              ratings.standard_deviation
            else
              nil
            end
          end
        end
      end

      # average the non-nils to get our volatility score
      stddev_ratings.reject(&:nil?).mean.round(1).to_f rescue 0.0
    end
  end

  def unity
    raise NotImplementedError unless klass.column_names.include?('rating')

    # unity = 1 - variance(ratings) / variance(max_rating, min_rating)
    @unity ||= begin
      maximum_variance = [Heartbeat::VALID_RATINGS.min, Heartbeat::VALID_RATINGS.max].variance

      unity_ratings = begin
        if live_mode?
          sample.complete.select("1.0 - (var_pop(rating) / #{maximum_variance}) as unity").group('users.manager_user_id').map(&:unity)
        else
          sample_managers_and_ratings = completed_sample.map { |s| [s.user.manager_user_id, s.rating.to_f] }

          ratings_by_manager = sample_managers_and_ratings.group_by(&:first).map { |manager_user_id, pairs| pairs.map(&:last) }

          ratings_by_manager.map do |ratings|
            1.0 - (ratings.variance / maximum_variance)
          end
        end
      end

      # average the non-nils to get our unity score
      unity_ratings.reject(&:nil?).mean.round(2).to_f rescue 0.0
    end
  end

  def shortest_time_to_completion
    sample.complete.select('min(completed_at - created_at) as completion_time')[0][:completion_time].try(:gsub, /^(\d+):(\d+):(\d+)\..*$/, '\1h \2m \3s')
  end


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
    @previous_results ||= Hash.new do |hash, key|
      hash[key] = self.class.new(source: source, period: period, start_date: start_date - (key * period).seconds)
    end

    @previous_results[n].presence
  end

  def next n = 1
    @next_results ||= Hash.new do |hash, key|
      hash[key] = self.class.new(source: source, period: period, start_date: start_date + (key * period).seconds)
    end

    @next_results[n].presence
  end

end
