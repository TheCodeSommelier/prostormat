class PlaceHideNotificationJob < ApplicationJob
  queue_as :default

  def perform(place_id, email)
    UserMailer.notify_owner_hidden_place(place_id, email).deliver_now
  end
end
