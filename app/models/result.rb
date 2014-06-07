class Result

  attr_accessor :start_time, :end_time
  attr_accessor :submissions, :metrics

  def initialize start_time, interval = :week
    raise ArgumentError if not [:week].include? interval

    self.start_time  = start_time
    self.end_time    = start_time.at_end_of_week

    self.submissions = Submission.complete.where(created_at: start_time..end_time)
    self.metrics     = Metric.where(id: @submissions.joins(:metrics).uniq('metrics.id').pluck('metrics.id')).to_a
  end

  def start_date
    start_time.to_date
  end

  def end_date
    end_time.to_date
  end

  def stats
    all_submissions = Submission.where(created_at: start_time..end_time)

    @stats ||= {
      response_rate: (all_submissions.complete.count.to_f / all_submissions.count.to_f),
      submission_count_completed: all_submissions.complete.count,
      submission_count: all_submissions.count,
    }
  end

  def ratings_by_metric
    metrics.map do |metric|
      submission_metrics = metric.submission_metrics.complete.where(submission: submissions)

      counts = submission_metrics.group(:rating).count

      # represent the zero counts
      counts = Hash[SubmissionMetric::VALID_RATINGS.map { |r| [r, 0] }].merge(counts)

      [metric, counts, submission_metrics]
    end
  end

end
