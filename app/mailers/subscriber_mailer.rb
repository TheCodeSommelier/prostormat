class SubscriberMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscriber_mailer.welcome_email.subject
  #
  def welcome_email(user)
    @greeting = "Vážený/á pane/paní #{user.last_name}"
    @place = user.place

    template_path = Rails.root.join('app', 'view', 'subscriber_mailer', 'welcome_email.html.erb')
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

    client = Postmark::APIcleint.new(ENV.fetch('POSTMARK_API_TOKEN'))
    client.deliver(email)
  end
end
