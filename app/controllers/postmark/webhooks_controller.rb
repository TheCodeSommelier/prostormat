class Postmark::WebhooksController < ApplicationController
  skip_before_action :authenticate_user!, :verify_authenticity_token, only: %i[order_status order_delivered]
  skip_after_action :verify_authorized, only: %i[order_status order_delivered]

  def order_status
    metadata = params['Metadata']
    order_id = metadata['OrderId'].to_i
    return unless order_id.is_a?(Integer)

    order = Order.find(order_id)

    order.update(unseen: false) if order.unseen
  end

  def order_delivered
    time = Time.iso8601(params['DeliveredAt'])
    metadata = params['Metadata']
    order_id = metadata['OrderId'].to_i
    return unless order_id.is_a?(Integer) && time.is_a?(Time)

    order = Order.find(order_id)

    order.update(delivered_at: time)
  end
end
