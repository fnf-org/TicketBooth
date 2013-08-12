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
    member do
      post :add_admin
      post :remove_admin
      get :guest_list
    end

    resources :jobs do
      resources :time_slots, only: [:new, :create, :edit, :update, :destroy]
    end

    resources :shifts, only: [:index, :create, :destroy]

    resources :ticket_requests do
      member do
        post :approve
        post :decline
        post :refund
      end
    end
  end

  resources :site_admins, only: [:index, :new, :create, :destroy]

  resource :webhook, controller: :web_hook, only: [:show, :create]
end
