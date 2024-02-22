class Stripe::CheckoutController < ApplicationController
  skip_after_action :verify_authorized

  def checkout
    session = Stripe::Checkout::Session.create(
      # automatic_payment_methods: { enabled: true },
      line_items: [{
        price: ENV.fetch('STRIPE_PRICE_ID'),
        quantity: 1
        }],
        mode: 'subscription',
        success_url: success_url,
        cancel_url: cancel_url
      )
    redirect_to session.url, allow_other_host: true
  end

  def success
  end

  def cancel
  end
end
