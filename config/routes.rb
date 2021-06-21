Rails.application.routes.draw do
  resources :users
  resources :tweets
  resources :comments
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'tweets#index'
  # post '/users/login/', to: 'users#login'
  
  # get "auth/:provider/callback", to: "sessions#googleAuth"
  # get "auth/failure", to: redirect("/")
  get '/comments/:id', to: 'comments#show'
  post '/comments/:id', to: 'comments#create'
  post '/tweets/:id', to: 'comments#create'
  get "users/:username", to: "users#show"
  
  devise_for :users, :controllers => { :omniauth_callbacks => 'users/omniauth' }
  end
