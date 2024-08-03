class SendFreeTrialEmailJob < ApplicationJob
  queue_as :default

  def perform(email, place_id)
    p "🔥 Got enqueued"
    UserMailer.notify_free_trial_start(email, place_id).deliver_now
  end
end
