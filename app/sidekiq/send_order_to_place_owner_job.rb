# frozen_string_literal: true

class SendOrderToPlaceOwnerJob < ApplicationJob
  queue_as :mailers

  def perform(place_id, bokee_id, message)
    @place          = Place.includes(:user).find(place_id)
    @bokee          = Bokee.find(bokee_id)
    @greeting       = "Vážený/á pane/paní #{@place.user.last_name}"
    @order_message  = message

    template_path   = Rails.root.join('app', 'views', 'mailers', 'send_order_to_place_owner_mailer.html.erb')
    template        = File.read(template_path)
    erb_template    = ERB.new(template)
    html_content    = erb_template.result(binding)

    email = {
      subject: 'Někdo má zájem o váš prostor!',
      to: Rails.env.production? ? @place.user.email : 'poptavka@prostormat.cz',
      from: 'poptavka@prostormat.cz',
      html_body: html_content,
      track_opens: 'true',
      message_stream: 'outbound'
    }

    client = Postmark::ApiClient.new(ENV.fetch('POSTMARK_API_TOKEN'))
    client.deliver(email)
  end
end
