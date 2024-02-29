class SubscriberMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscriber_mailer.welcome_email.subject
  #
  def welcome_email(user)
    @greeting = "Vážený/á pane/paní #{user.last_name}"
    @place = user.place

    mail(
      subject: 'Děkujeme Vám za vaší registraci',
      to: user.email,
      from: 'poptavka@prostormat.cz',
      track_opens: 'true',
      message_stream: 'broadcast'
    )
  end
end
