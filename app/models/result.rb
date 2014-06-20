class Result
  include ActiveModel::Model

  attr_accessor :start_time, :end_time
  attr_accessor :submissions, :metrics

  def initialize start_time, interval = :week
    raise ArgumentError if not [:week].include? interval

    self.start_time  = start_time
    self.end_time    = start_time.at_end_of_week

    self.submissions = Submission.where(created_at: start_time..end_time)
    self.metrics     = Metric.where(id: @submissions.joins(:metrics).uniq('metrics.id').pluck('metrics.id')).to_a
  end

  def persisted?
    end_time < Time.now
  end

  def to_key
    [end_date.strftime('%Y%m%d')]
  end

  def start_date
    start_time.to_date
  end

  def end_date
    end_time.to_date
  end

  def previous
    @previous ||= self.class.new(start_time - 1.week)
  end

  def next
    if end_time + 1.week < Time.now
      @next ||= self.class.new(start_time + 1.week)
    end
  end

  def stats
    @stats ||= {
      response_rate: (submissions.complete.count.to_f / submissions.count.to_f),
      submission_count_completed: submissions.complete.count,
      submission_count: submissions.count,
      average_response_time: submissions.complete.select('avg(completed_at - created_at) as completion_time')[0][:completion_time].gsub(/^(\d+):(\d+):(\d+)\..*$/, '\1h \2m \3s'),
      best_response_time: submissions.complete.select('min(completed_at - created_at) as completion_time')[0][:completion_time].gsub(/^(\d+):(\d+):(\d+)\..*$/, '\1h \2m \3s'),
    }
  end

  def result_metrics
    @result_metrics ||= begin
      metrics.map do |metric|
        ResultMetric.new(
          result: self,
          metric: metric,
          submission_metrics: metric.submission_metrics.where(submission: submissions),
        )
      end
    end
  end

  def comments
    @comments ||= begin
      submissions.reject { |s| s.comments.blank? }.map do |s|
        {
          user:    s.user,
          content: s.comments,
          public:  s.comments_public,
        }
      end
    end
  end

  def public_comments
    comments.select { |c| c[:public] }
  end

end
