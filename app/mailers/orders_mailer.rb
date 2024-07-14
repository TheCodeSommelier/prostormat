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
end
