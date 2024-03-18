class ContactEmailJob < ApplicationJob
  queue_as :mailers

  def perform(contact_form_params)
    @name           = contact_form_params[:name]
    @customer_email = contact_form_params[:email]
    @message        = contact_form_params[:message]
    @mailto_link    = "mailto:#{@customer_email}?subject=Prostormat - Customer Support"

    template_path   = Rails.root.join('app', 'views', 'mailers', 'contact_email.html.erb')
    template        = File.read(template_path)
    erb_template    = ERB.new(template)
    html_content    = erb_template.result(binding)

    email = {
      subject: 'Dotaz z contact us',
      to: 'info@prostormat.cz',
      from: 'info@prostormat.cz',
      html_body: html_content,
      message_stream: 'outbound'
    }

    client = Postmark::ApiClient.new(ENV.fetch('POSTMARK_API_TOKEN'))
    client.deliver(email)
  end
end
