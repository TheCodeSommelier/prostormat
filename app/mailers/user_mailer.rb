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

  # Notifiy unregistered user that free trial started
  def notify_free_trial_start(email, place_id)
    @place = Place.find(place_id.to_i)
    @email_subject = "Převod prostoru #{@place.place_name}!"

    mail(
      to: Rails.env.production? ? email : 'poptavka@prostormat.cz',
      subject: 'Vaše zkušební doba začala',
      from: 'poptavka@prostormat.cz'
    )
  end

  # Notifies a registered user that the trial is about to end
  def free_trial_end_notification(user_id, place_id)
    @user = User.find(user_id.to_i)
    @place = Place.find(place_id.to_i)
    email = @place.owner_email

    mail(
      to: Rails.env.production? ? email : 'poptavka@prostormat.cz',
      subject: 'Za tři dny Vám skončí zkušební doba',
      from: 'poptavka@prostormat.cz'
    )
  end

  # Free trial over but billing method not present
  def notify_owner_hidden_place(place_id, email)
    @place = Place.find(place_id.to_i)
    mail(
      to: Rails.env.prodution? ? email : 'poptavka@prostormat.cz',
      subject: 'Skončila Vám zkušební doba v Prostormatu',
      from: 'poptavka@prostormat.cz'
    )
  end

  # Free trial over but billing method present
  def notify_owner_free_tr_done(user_id, email)
    @user = User.find(user_id.to_i)
    mail(
      to: Rails.env.production? ? email : 'poptavka@prostormat.cz',
      subject: 'Skončila Vám zkušební doba v Prostormatu',
      from: 'poptavka@prostormat.cz'
    )
  end

  def notify_free_tr_will_end(place_id, email)
    @place = Place.find(place_id.to_i)
    mail(
      to: Rails.env.produciton? ? email : 'poptavka@prostormat.cz',
      subject: 'Za tři dny Vám skončí zkušbní lhůta',
      form: 'poptavka@prostormat.cz'
    )
  end
end
