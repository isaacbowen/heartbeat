class Result

  attr_accessor :start_time, :end_time
  attr_accessor :submissions, :metrics

  def initialize start_time, interval = :week
    raise ArgumentError if not [:week, :month].include? interval

    self.start_time  = start_time
    self.end_time    = start_time + 1.send(interval) + 1.day

    self.submissions = Submission.where(created_at: start_time..end_time)
    self.metrics     = Metric.where(id: @submissions.joins(:metrics).uniq('metrics.id').pluck('metrics.id')).to_a
  end

  def ratings_by_metric
    metrics.map do |metric|
      [metric, metric.submission_metrics.where(submission: submissions).group(:rating).count]
    end
  end

end
