# frozen_string_literal: true

# StripeController handles the integration with Stripe payment services.
# It manages the creation of new checkout sessions for handling payments
# and subscriptions, and processes incoming webhooks for various Stripe event
class StripeController < ApplicationController
  # Creates a new Stripe Checkout session and redirects the user to the
  # Stripe payment form for completing the transaction.
  def new_checkout_session; end

  # Receives and processes webhook events from Stripe, such as subscription
  # updates, payment successes, or failures.
  def webhooks; end
end
