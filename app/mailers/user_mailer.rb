# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email(user_id)
    @user = User.find(user_id.to_i)
    @greeting = "Vážený/á pane/paní <span class='highlight'>#{@user.last_name}</span>"

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

  # [UNREGISTERED USER --- MAILING METHODS]

  # Notifiy unregistered user that free trial started
  def unregistered_user_trial_started(email, place_id)
    @place = Place.find(place_id.to_i)
    @email_subject = "Převod prostoru #{@place.place_name}!"

    mail(
      to: Rails.env.production? ? email : 'poptavka@prostormat.cz',
      subject: 'Vaše zkušební doba začala',
      from: 'poptavka@prostormat.cz'
    )
  end

  # No account but free trial almost done
  def trial_ending_no_account(place_id, email)
    @place = Place.find(place_id.to_i)
    mail(
      to: Rails.env.produciton? ? email : 'poptavka@prostormat.cz',
      subject: 'Za tři dny Vám skončí zkušební lhůta',
      form: 'poptavka@prostormat.cz'
    )
  end

  # Notifiy unregistered user that free trial ended
  def unregistered_user_trial_ended(place_id, email)
    @place = Place.find(place_id.to_i)
    @email_subject = "Převod prostoru #{@place.place_name}!"

    mail(
      to: Rails.env.production? ? email : 'poptavka@prostormat.cz',
      subject: 'Vaše zkušební doba skončila',
      from: 'poptavka@prostormat.cz'
    )
  end

  # [REGISTERED USER --- MAILING METHODS]

  # Notifies a registered user that the trial is about to end
  def registered_user_trial_ending(user_id, place_id)
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
  def trial_ended_no_billing(place_id, email)
    @place = Place.find(place_id.to_i)
    mail(
      to: Rails.env.prodution? ? email : 'poptavka@prostormat.cz',
      subject: 'Skončila Vám zkušební doba v Prostormatu',
      from: 'poptavka@prostormat.cz'
    )
  end

  # Free trial over and billing method present
  def trial_ended_with_billing(user_id, email)
    @user = User.find(user_id.to_i)
    mail(
      to: Rails.env.production? ? email : 'poptavka@prostormat.cz',
      subject: 'Skončila Vám zkušební doba v Prostormatu',
      from: 'poptavka@prostormat.cz'
    )
  end

  # Send monthly invoice
  def monthly_invoice(stripe_customer_id, invoice_id)
    @user = User.find_by(stripe_customer_id:)
    error_message = "🔥 User not found for invoice mailing: stripe_customer_id: #{stripe_customer_id}"
    logger.error error_message and return unless @user

    invoice = Stripe::Invoice.retrieve(invoice_id)
    @invoice_pdf_link = invoice.invoice_pdf

    mail(
      to: Rails.env.production? ? @user.email : 'poptavka@prostormat.cz',
      subject: 'Váš účet za minulý měsíc'
    )
  end
end
