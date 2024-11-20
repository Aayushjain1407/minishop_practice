Rails.application.routes.draw do
  resources :orders
  resources :cart_items
  resources :carts
  resources :reviews
  resources :purchases
  resources :products do
    post "buy", on: :member
    get "reviews", on: :member
  end

  post "/webhook", to: "products#webhook"

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "products#index"
end
