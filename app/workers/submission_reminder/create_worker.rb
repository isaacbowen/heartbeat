class SubmissionReminder::CreateWorker
  include Sidekiq::Worker

  def perform options = {}
  end
end
