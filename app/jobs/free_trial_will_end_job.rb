class FreeTrialWillEndJob < ApplicationJob
  queue_as :default

  def perform(place_id, email)
    UserMailer.notify_free_tr_will_end(place_id, email).deliver_now
  end
end
