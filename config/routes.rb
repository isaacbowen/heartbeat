Rails.application.routes.draw do

  root 'meta#root'

  # temporary haaaack
  if Rails.env.development?
    post '/hit-me', to: 'meta#hit_me'
  end

  resource :user, path: '/me', only: [:show, :update, :edit] do
    get :history, on: :member
  end

  resources :submissions, only: [:show, :edit, :update]

  resources :results, only: [:index, :show]

  namespace :admin do
    root 'meta#root'

    resources :users do
      collection do
        get  'import', action: :import
        post 'import', action: :import
      end
    end

    resources :results
    resources :submission_reminder_templates
  end

end
