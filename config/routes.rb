Rails.application.routes.draw do

  root 'meta#root'

  # temporary haaaack
  post '/hit-me', to: 'meta#hit_me'

  resources :submissions, only: [:show, :update]

  resources :results, only: [:index, :show]

  namespace :admin do
    root 'meta#root'

    resources :users
    resources :metrics
  end

end
