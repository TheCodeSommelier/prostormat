# frozen_string_literal: true

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
      to: Rails.env.production? ? @email : 'poptavka@prostormat.cz',
      subject: contact_form_params[:subject],
      from: 'poptavka@prostormat.cz'
    )
  end

  def notify_free_trial_start(email, place_id)
    @place = Place.find(place_id.to_i)
    @email_subject = "Převod prostoru #{@place.place_name}!"

    mail(
      to: Rails.env.production? ? email : 'poptavka@prostormat.cz',
      subject: 'Vaše zkušební doba začala',
      from: 'poptavka@prostormat.cz'
    )
  end

  def free_trial_end_notification(email, place_id)
    @place = Place.find(place_id.to_i)
    @email_subject = "Převod prostoru #{@place.place_name}!"

    mail(
      to: Rails.env.production? ? email : 'poptavka@prostormat.cz',
      subject: 'Vaše zkušební doba zkončila',
      from: 'poptavka@prostormat.cz'
    )
  end
end
