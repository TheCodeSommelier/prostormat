# frozen_string_literal: true

if Rails.env.production?
  # Use live keys in production
  Stripe.api_key = ENV.fetch('STRIPE_LIVE_SECRET_KEY')
  Rails.application.config.x.stripe.publishable_key = ENV.fetch('STRIPE_LIVE_PUBLISHABLE_KEY')
  Rails.application.config.x.stripe.price_id = ENV.fetch('STRIPE_LIVE_PRICE_ID')
else
  # Use test keys in development and other environments
  Stripe.api_key = ENV.fetch('STRIPE_TEST_SECRET_KEY')
  Rails.application.config.x.stripe.publishable_key = ENV.fetch('STRIPE_TEST_PUBLISHABLE_KEY')
  Rails.application.config.x.stripe.price_id = ENV.fetch('STRIPE_TEST_PRICE_ID')
end
