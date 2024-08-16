# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # TODO: Fix sidekiq UI
  require 'sidekiq/web'
  authenticate :user, ->(user) { user.dev? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#landing_page'

  get 'about_us', to: 'pages#about_us'
  get 'faq_contact', to: 'pages#faq_contact_us', as: 'faq_contact'
  get 'new_bulk_order', to: 'pages#new_bulk_order', as: 'new_bulk_order'
  get 'overload', to: 'pages#overload'

  # ⬇️⬇️⬇️⬇️⬇️ NEEDS CONTENT ⬇️⬇️⬇️⬇️⬇️
  get 'why_us', to: 'pages#why_us'
  get 'pricing', to: 'pages#pricing'
  get 'for_owners', to: 'pages#for_owners'
  get 'free_trial_info', to: 'pages#free_trial_info'
  get 'privacy_policy', to: 'pages#privacy_policy'
  get 'terms_service', to: 'pages#terms_service'
  get 'cookie_consent', to: 'pages#cookie_consent'

  post 'contact', to: 'pages#contact'
  post 'create_bulk_order', to: 'pages#create_bulk_order'

  post '/verify-turnstile', to: 'application#verify_turnstile_token_ajax'

  get 'admin_places', to: 'places#admin_places', as: :admin_places
  resources :places, param: :slug do
    resources :orders, only: %i[create update]
    member do
      patch 'transfer', to: 'places#transfer', as: :transfer
      patch 'toggle_primary', to: 'places#toggle_primary', as: 'toggle_primary'
    end
  end

  namespace :postmark do
    post 'order_status', to: 'webhooks#order_status'
    post 'order_delivered', to: 'webhooks#order_delivered'
  end

  # Stripe Checkout route for creating a new subscription
  get 'stripe/checkout', to: 'stripe/checkout#checkout'

  # Stripe Webhook route for handling events
  # stripe listen --forward-to localhost:3000/stripe/webhooks
  post 'stripe/webhooks', to: 'stripe/webhooks#create'

  get 'stripe/checkoutcomplete', to: 'stripe/checkout#success', as: :checkout_success
  get 'checkout/cancel', to: 'stripe/checkout#cancel', as: :checkout_cancel
  post 'stripe/billing', to: 'stripe/billing#create'
  post 'stripe/create-subscription', to: 'stripe/checkout#create_subscription'
  post 'stripe/create-setup-intent', to: 'stripe/checkout#setup_intent'
end
