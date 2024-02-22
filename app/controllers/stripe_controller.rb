# frozen_string_literal: true

# StripeController handles the integration with Stripe payment services.
# It manages the creation of new checkout sessions for handling payments
# and subscriptions, and processes incoming webhooks for various Stripe event
class StripeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new_checkout_session webhooks] # Skip authentication for index
  skip_after_action :verify_authorized

  # Creates a new Stripe Checkout session and redirects the user to the
  # Stripe payment form for completing the transaction.
  def new_checkout_session
    # You might want to find or create a product/subscription plan here, or pass these as parameters
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        # Assuming you have a subscription plan already created in your Stripe dashboard
        price: ENV.fetch('STRIPE_PRICE_ID'),
        quantity: 1
      }],
      mode: 'subscription',
      success_url: success_url,
      cancel_url: cancel_url
    )

    redirect_to session.url, allow_other_host: true
  end

  # Receives and processes webhook events from Stripe, such as subscription
  # updates, payment successes, or failures.
  def webhooks; end

  def success
    # redirect_to place_path(@place)
  end

  def cancel
  end
end
