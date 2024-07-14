# frozen_string_literal: true

class OrdersMailer < ApplicationMailer
  def notify_owner(place, order)
    @place = place
    @bokee = order.bokee
    @greeting = "Vážený/á pane/paní <span class='highlight'>#{@place.user.last_name}</span>"
    @order = order

    mail.headers['X-PM-TrackOpens'] = 'true'
    mail.headers['X-PM-Message-Stream'] = 'outbound'

    mail(
      to: Rails.env.production? ? @place.user.email : 'poptavka@prostormat.cz',
      subject: 'Někdo má zájem o váš prostor!',
      from: 'poptavka@prostormat.cz'
    )
  end

  def send_bulk_order(places_ids, bulk_order_params)
    @places = Place.includes(:user).where(id: places_ids)
    @email        = bulk_order_params[:email]
    @name         = bulk_order_params[:full_name]
    @date         = bulk_order_params[:date]
    @meassage     = bulk_order_params[:message]

    mail.headers['X-PM-TrackOpens'] = 'true'
    mail.headers['X-PM-Message-Stream'] = 'outbound'

    mail(
      to: 'poptavka@prostormat.cz',
      subject: "Hromadná poptávka od: #{bulk_order_params[:full_name]}",
      from: 'poptavka@prostormat.cz'
    )
  end
end
