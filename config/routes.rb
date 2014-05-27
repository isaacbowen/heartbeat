Rails.application.routes.draw do

  root to: 'meta#root'

  resources :submissions, only: [:show, :update]

  resources :results, only: [:index, :show]

end
