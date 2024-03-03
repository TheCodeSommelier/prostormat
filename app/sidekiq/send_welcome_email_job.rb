class SendWelcomeEmailJob < ApplicationJob
  queue_as :mailers

  def perform(user_id)
    user = User.find(user_id.to_i)
    @greeting = "Vážený/á pane/paní #{user.last_name}"
    @place = user.place

    template_path = Rails.root.join('app', 'views', 'subscriber_mailer', 'welcome_email.html.erb')
    template      = File.read(template_path)
    erb_template  = ERB.new(template)
    html_content  = erb_template.result(binding)

    email = {
      subject: 'Děkujeme Vám za vaší registraci',
      to: user.email,
      from: 'poptavka@prostormat.cz',
      html_body: html_content,
      track_opens: 'true',
      message_stream: 'broadcast'
    }

    client = Postmark::ApiClient.new(ENV.fetch('POSTMARK_API_TOKEN'))
    client.deliver(email)
  end
end
