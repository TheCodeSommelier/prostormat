# frozen_string_literal: true

class SendOrderToPlaceOwnerJob < ApplicationJob
  queue_as :mailers

  def perform(place_id, order_id)
    place = Place.includes(:user).find(place_id.to_i)
    order = Order.includes(:bokee).find(order_id.to_i)

    OrdersMailer.notify_owner(place, order).deliver_now
  end
end
