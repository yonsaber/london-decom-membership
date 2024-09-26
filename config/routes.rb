Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', confirmations: 'users/confirmations' }
  get 'confirmation_notice', to: 'home#confirmation_notice', as: :confirmation_notice

  namespace :admin do
    resources :users do
      collection do
        get :unconfirmed
      end
      member do
        patch :give_direct_sale
      end
    end
    resources :membership_codes
    resources :low_income_codes
    resources :low_income_requests, only: %i[index] do
      member do
        post :approve
        post :reject
      end
    end
    resources :events, only: %i[index show new create update edit] do
      resources :volunteer_roles do
        resources :volunteers
      end
    end
  end
  resources :events, only: %i[patch] do
    patch :clear_discount_from_cache
    resources :volunteer_roles, only: [] do
      resources :volunteers, only: %i[index new create destroy update]
    end
  end
  resources :low_income_requests
  root to: 'home#index'

  %w[400 404 422 500 503].each do |code|
    get code, to: 'errors#show', code:
  end

  match '*any', to: 'errors#show', code: 404, via: :all if Rails.env.production?
end
