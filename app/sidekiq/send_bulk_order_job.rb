# frozen_string_literal: true

class SendBulkOrderJob < ApplicationJob
  queue_as :mailers

  def perform(places_ids, email, name, message, date)
    @places       = Place.includes(:user).where(id: places_ids)
    @email        = email
    @name         = name
    @date         = date
    @meassage     = message
    template_path = Rails.root.join('app', 'views', 'mailers', 'send_bulk_order_to_admin.html.erb')
    template      = File.read(template_path)
    erb_template  = ERB.new(template)
    html_content  = erb_template.result(binding)

    email = {
      subject: "Hromadná poptávka od: #{@name}",
      to: 'poptavka@prostormat.cz',
      from: 'poptavka@prostormat.cz',
      html_body: html_content,
      track_opens: 'true',
      message_stream: 'outbound'
    }

    client = Postmark::ApiClient.new(ENV.fetch('POSTMARK_API_TOKEN'))
    client.deliver(email)
  end
end
