# frozen_string_literal: true

class OrdersMailer < ApplicationMailer
  def notify_owner(place, order)
    @place = place
    @bokee = order.bokee
    @greeting = "Vážený/á pane/paní <span class='highlight'>#{@place.user.last_name}</span>"
    @order = order

    metadata['OrderId'] = @order.id.to_s

    mail(
      to: Rails.env.production? ? @place.owner_email : 'poptavka@prostormat.cz',
      subject: 'Někdo má zájem o váš prostor!',
      from: 'poptavka@prostormat.cz',
      track_opens: true,
      message_stream: 'outbound'
    )
  end

  def remind_owner(place, order)
    @place = place
    @bokee = order.bokee
    @greeting = "Vážený/á pane/paní <span class='highlight'>#{@place.user.last_name}</span>"
    @order = order

    mail(
      to: Rails.env.production? ? @place.owner_email : 'poptavka@prostormat.cz',
      subject: 'Před třemi dny jste dostali tuto objednávku! Zákazník čeká!',
      from: 'poptavka@prostormat.cz',
      message_stream: 'outbound'
    )
    @order.update(notified: true)
  end

  def send_bulk_order(places_ids, bulk_order_params)
    @places       = Place.includes(:user).where(id: places_ids)
    @email        = bulk_order_params[:email]
    @name         = bulk_order_params[:full_name]
    @date         = Date.parse(bulk_order_params[:date])
    @message      = bulk_order_params[:message]

    mail.headers['X-PM-TrackOpens'] = 'true'
    mail.headers['X-PM-Message-Stream'] = 'outbound'

    mail(
      to: 'poptavka@prostormat.cz',
      subject: "Hromadná poptávka od: #{bulk_order_params[:full_name]}",
      from: 'poptavka@prostormat.cz'
    )
  end
end
