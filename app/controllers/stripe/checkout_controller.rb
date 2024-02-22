class Stripe::CheckoutController < ApplicationController
  skip_after_action :verify_authorized

  def checkout
    session = Stripe::Checkout::Session.create(
      customer: current_user.stripe_customer_id,
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
    place = current_user.place
    flash.now[:alert] = 'Máte zaplaceno'
    redirect_to place_path(place)
  end

  def cancel
    place = current_user.place
    flash.now[:alert] = 'Něco se pokazilo... Zkuste to znovu prosím.'
    redirect_to new_place_path(place)
  end
end
