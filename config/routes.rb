Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#landing_page'

  get 'admin_places', to: 'places#admin_places', as: :admin_places
  resources :places do
    # For tax purposes "update" will "cancel" the order. Even if an order is cancelled it still needs to be in DB
    resources :orders, only: %i[create update]
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

  # TODO: Fix sidekiq UI
  require 'sidekiq/web'
  authenticate :user, ->(user) { user.dev? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
