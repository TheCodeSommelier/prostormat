class NotifyPlaceOwnerTrialEndJob < ApplicationJob
  queue_as :default

  def perform(user_id, place_id)
    UserMailer.free_trial_end_notification(user_id, place_id).deliver_now
  end
end
