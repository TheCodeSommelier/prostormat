# frozen_string_literal: true

module Stripe
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def create
      # Replace this endpoint secret with your endpoint's unique secret
      # If you are testing with the CLI, find the secret by running 'stripe listen'
      # If you are using an endpoint defined with the API or dashboard, look in your webhook settings
      # at https://dashboard.stripe.com/webhooks
      webhook_secret = ENV.fetch('STRIPE_WEBHOOK_SECRET')
      payload = request.body.read
      if !webhook_secret.empty?
        # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        event = nil

        begin
          event = Stripe::Webhook.construct_event(
            payload, sig_header, webhook_secret
          )
        rescue JSON::ParserError
          # Invalid payload
          status 400
          return
        rescue Stripe::SignatureVerificationError
          # Invalid signature
          puts '⚠️  Webhook signature verification failed.'
          status 400
          return
        end
      else
        data = JSON.parse(payload, symbolize_names: true)
        event = Stripe::Event.construct_from(data)
      end
      # Get the type of webhook event sent - used to check the status of PaymentIntents.
      data = event['data']
      subscription_data = data['object']

      if event.type == 'customer.created'
        customer = event.data.object
        user = User.find_by(email: customer.email)
        user.update(stripe_customer_id: customer.id)
      end

      if event.type == 'customer.subscription.deleted'
        # handle subscription canceled automatically based
        # upon your subscription settings. Or if the user cancels it.
        customer = User.find_by(stripe_customer_id: subscription_data.customer)
        customer.update(premium: false)
        customer.places.first.update(hidden: true)
      end

      if event.type == 'customer.subscription.updated'
        # handle subscription updated
        # puts data_object
        customer = User.includes(:places).find_by(stripe_customer_id: subscription_data.customer)
        place = customer.places.first
        case subscription_data.status
        when 'active' then UserMailer.trial_ended_with_billing(customer.id, place.owner_email).deliver_later
        else
          place.update(hidden: true)
          customer.update(premium: false)
          UserMailer.trial_ended_no_billing(place.id, place.owner_email).deliver_later
        end
      end

      if event.type == 'customer.subscription.created'
        # handle subscription created
        # puts data_object
        customer = User.find_by(stripe_customer_id: subscription_data.customer)
        customer.update(premium: true)
        customer.places.first.update(hidden: false)
        UserMailer.welcome_email(customer.id).deliver_later
      end

      if event.type == 'customer.subscription.trial_will_end'
        # handle subscription trial ending
        # puts data_object
        user = User.includes(:places).find_by(stripe_customer_id: subscription_data.customer)
        place = user.places.first
        UserMailer.registered_user_trial_ending(user.id, place.id).deliver_later
      end

      if event.type == 'invoice.paid' && subscription_data.amount_due.to_i.positive?
        UserMailer.monthly_invoice(subscription_data.customer, subscription_data.id).deliver_later
      end

      render json: { message: 'success' }
    end
  end
end
