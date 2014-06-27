Cloudwatch::Application.routes.draw do
  root to: 'home#index'

  devise_for :users

  get 'fnf-tickets', controller: :ticket_requests, action: :new, event_id: 1
  get 'fnf_tickets', controller: :ticket_requests, action: :new, event_id: 1
  get 'fnftickets', controller: :ticket_requests, action: :new, event_id: 1
  get 'fnf', controller: :ticket_requests, action: :new, event_id: 1
  get 'FNF', controller: :ticket_requests, action: :new, event_id: 1
  get 'FnF', controller: :ticket_requests, action: :new, event_id: 1

  resources :payments, only: [:new, :create, :show] do
    collection do
      get :other
      post :sent
      post :mark_received
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
      collection do
        get :download
      end

      member do
        post :approve
        post :decline
        post :refund
        post :resend_approval
      end
    end
  end

  resources :site_admins, only: [:index, :new, :create, :destroy]

  resource :webhook, controller: :web_hook, only: [:show, :create]
end
