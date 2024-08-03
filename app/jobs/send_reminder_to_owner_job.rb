# frozen_string_literal: true

class SendReminderToOwnerJob < ApplicationJob
  queue_as :default

  def perform(place_id, order_id)
    place = Place.includes(:user).find(place_id.to_i)
    order = Order.includes(:bokee).find(order_id.to_i)

    OrdersMailer.remind_owner(place, order).deliver_now
  end
end
