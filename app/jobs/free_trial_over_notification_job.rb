class FreeTrialOverNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, email)
    UserMailer.notify_owner_free_tr_done(user_id, email).deliver_now
  end
end
