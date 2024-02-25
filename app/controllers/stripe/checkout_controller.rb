class Stripe::CheckoutController < ApplicationController
  skip_after_action :verify_authorized
  # TODO: Handle errors upon payments

  def checkout; end

  def setup_intent
    setup_intent = Stripe::SetupIntent.create({
      payment_method_types: ['card']
    })

    render json: { clientSecret: setup_intent.client_secret }
  end

  def create_subscription
    customer_id = current_user.stripe_customer_id
    payment_method_id = params[:payment_method_id]

    Stripe::PaymentMethod.attach(
      payment_method_id,
      { customer: customer_id }
    )

    Stripe::Customer.update(
      customer_id, {
        invoice_settings: { default_payment_method: payment_method_id }
      }
    )

    Stripe::Subscription.create({
        customer: customer_id,
        items: [{ price: ENV.fetch('STRIPE_PRICE_ID') }],
        currency: 'czk',
        expand: ['latest_invoice.payment_intent']
      }
    )
    render json: {  }
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
