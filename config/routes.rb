Rails.application.routes.draw do

  root to: 'meta#root'

  resources :submissions, only: [:show, :update]

  get 'results', to: 'results#index'
  get 'results/:start_date-:end_date', to: 'results#show'

end
