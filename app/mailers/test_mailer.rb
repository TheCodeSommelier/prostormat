class TestMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.test_mailer.hello.subject
  #
  def hello
    @greeting = 'Hi'

    mail(
      subject: 'Hello from Postmark',
      to: 'poptavka@prostormat.cz',
      from: 'poptavka@prostormat.cz',
      track_opens: 'true',
      message_stream: 'outbound'
    )
  end
end
