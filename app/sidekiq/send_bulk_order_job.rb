# frozen_string_literal: true

class SendBulkOrderJob < ApplicationJob
  queue_as :mailers

  def perform(places_ids, bulk_order_params)
    OrdersMailer.send_bulk_order(places_ids, bulk_order_params).deliver_now
  end
end
