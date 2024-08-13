# frozen_string_literal: true

module Stripe
  class CheckoutController < ApplicationController
    skip_after_action :verify_authorized

    def checkout
      return unless session[:free_trial_end].present?

      @place = current_user.places.first
      @is_free_trial = @place.free_trial_end > Time.current
      @time_to_pay = @place.free_trial_end.strftime('%d.%m.%Y')
    end

    def fetch_price
      price_id = Rails.env.production? ? ENV.fetch('STRIPE_TEST_LIVE_ID') : ENV.fetch('STRIPE_TEST_PRICE_ID')
      price = Stripe::Price.retrieve(price_id)

      render json: price
    end

    def setup_intent
      setup_intent = Stripe::SetupIntent.create({
                                                  payment_method_types: ['card']
                                                })

      render json: { clientSecret: setup_intent.client_secret }
    end

    def create_subscription
      customer_id = current_user.stripe_customer_id
      payment_method_id = params[:payment_method_id]
      trial_end = session[:free_trial_end].present? ? Time.parse(session[:free_trial_end]).to_i : 'now'

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
                                    items: [{ price: Rails.application.config.x.stripe.price_id }],
                                    currency: 'czk',
                                    expand: ['latest_invoice.payment_intent'],
                                    trial_end:
                                  })
    end

    def success
      place = current_user.places.first
      flash[:notice] = 'Máte zaplaceno'
      redirect_to place_path(place.slug)
    end

    def cancel
      place = current_user.places.first
      flash[:alert] = 'Něco se pokazilo... Zkuste to znovu prosím.'
      redirect_to new_place_path(place.slug)
    end
  end
end
