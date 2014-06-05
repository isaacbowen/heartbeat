Rails.application.routes.draw do

  root 'meta#root'

  # temporary haaaack
  if Rails.env.development?
    post '/hit-me', to: 'meta#hit_me'
  end

  resources :submissions, only: [:show, :update]

  resources :results, only: [:index, :show]

  namespace :admin do
    root 'meta#root'

    resources :users do
      collection do
        get  'import', action: :import
        post 'import', action: :import
      end
    end

    resources :submissions do
      collection do
        post 'batch', action: :batch
      end
    end
  end

end
