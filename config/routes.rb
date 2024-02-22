Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#landing_page'

  resources :places do
    # For tax purposes "update" will "cancel" the order. Even if an order is cancelled it still needs to be in DB
    resources :orders, only: %i[new create update]
  end

  # Stripe Checkout route for creating a new subscription
  get 'stripe/checkout', to: 'stripe#new_checkout_session', as: :new_checkout_session

  # Stripe Webhook route for handling events
  post 'stripe/webhooks', to: 'stripe#webhooks'

  get 'success', to: 'stripe#success'
  get 'cancel', to: 'stripe#cancel'
end
