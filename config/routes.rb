Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :places, only: %i[index show new create update destroy] do
    resources :venues, only: %i[show] do
      # For tax purposes "update" will "cancel" the order. Even if an order is cancelled it still needs to be in DB
      resources :orders, only: %i[new create update]
    end
  end
end
