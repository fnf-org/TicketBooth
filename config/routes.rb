Cloudwatch::Application.routes.draw do
  root to: 'home#index'

  devise_for :users

  resources :payments, only: [:new, :create, :show] do
    collection do
      get :other
      post :sent
    end
  end

  resources :events do
    resources :jobs do
      resources :time_slots, only: [:new, :create, :edit, :update, :destroy]
    end
    resources :shifts, only: [:index, :create, :destroy]

    resources :ticket_requests do
      member do
        post :approve
        post :decline
      end
    end
  end

  resources :site_admins, only: [:index, :new, :create, :destroy]
end
