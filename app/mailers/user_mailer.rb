class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @greeting = "Vážený/á pane/paní <span class='highlight'>#{user.last_name}</span>"

    mail.headers['X-PM-TrackOpens'] = 'true'
    mail.headers['X-PM-Message-Stream'] = 'outbound'

    mail(
      to: Rails.env.production? ? @user.email : 'poptavka@prostormat.cz',
      subject: 'Děkujeme Vám za vaší registraci',
      from: 'poptavka@prostormat.cz'
    )
  end

  def contact_us_email(contact_form_params)
    @name    = contact_form_params[:name]
    @message = contact_form_params[:message]
    @email   = contact_form_params[:email]

    mail.headers['X-PM-TrackOpens'] = 'true'
    mail.headers['X-PM-Message-Stream'] = 'outbound'

    mail(
      to: 'poptavka@prostormat.cz',
      subject: contact_form_params[:subject],
      from: Rails.env.production? ? @email : 'poptavka@prostormat.cz'
    )
  end
end
