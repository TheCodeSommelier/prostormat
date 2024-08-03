class NotifyOwnerPlaceHiddenJob < ApplicationJob
  queue_as :default

  def perform(user_email, place_id)
    p "🔥 Started from the schedule now we notify!"
    UserMailer.free_trial_end_notification(user_email, place_id).deliver_now
  end
end
