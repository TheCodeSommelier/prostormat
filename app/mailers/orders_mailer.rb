# frozen_string_literal: true

class OrdersMailer < ApplicationMailer
  def notify_owner(place_id, order_id)
    @place = Place.includes(:user).find(place_id.to_i)
    @order = Order.includes(:bokee).find(order_id.to_i)
    @bokee = @order.bokee
    @greeting = "Vážený/á pane/paní <span class='highlight'>#{@place.user.last_name}</span>"

    metadata['OrderId'] = @order.id.to_s

    mail(
      to: Rails.env.production? ? @place.owner_email : 'poptavka@prostormat.cz',
      subject: 'Někdo má zájem o váš prostor!',
      from: 'poptavka@prostormat.cz',
      track_opens: true,
      message_stream: 'outbound'
    )
  end

  def remind_owner(place_id, order_id)
    @place = Place.includes(:user).find(place_id.to_i)
    @order = Order.includes(:bokee).find(order_id.to_i)
    @bokee = @order.bokee
    @greeting = "Vážený/á pane/paní <span class='highlight'>#{@place.user.last_name}</span>"

    mail(
      to: Rails.env.production? ? @place.owner_email : 'poptavka@prostormat.cz',
      subject: 'Před třemi dny jste dostali tuto objednávku! Zákazník čeká!',
      from: 'poptavka@prostormat.cz',
      message_stream: 'outbound'
    )
    @order.update(notified: true)
  end
end
