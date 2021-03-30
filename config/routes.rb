Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html\

  root 'welcome#index'
  resources :users, only: [:new, :create]

  get '/login', to: 'session#new'
  post '/login', to: 'session#create'
  delete '/logout', to: 'session#destroy'
  get '/logout', to: 'session#destroy'

  resources :parties, only: [:new, :create]
  post '/parties/new', to: 'parties#create'

  resource :dashboard, controller: 'users', only: :show do
    resources :friendships, only: [:create]
  end

  resources :movies, only: :show
  get '/discover', to: 'movies#index'
  post '/discover', to: 'movies#index'
end
