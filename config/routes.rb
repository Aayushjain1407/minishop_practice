Rails.application.routes.draw do
  resources :orders
  resources :cart_items
  resource :cart, only: [:show] do
    post :checkout, on: :member
  end
  resources :reviews
  resources :purchases
  resources :products do
    post "buy", on: :member
    get "reviews", on: :member
  end

  post "/webhooks/stripe", to: "webhooks#stripe"

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "products#index"
end
