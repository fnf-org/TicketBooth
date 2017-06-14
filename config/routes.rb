Cloudwatch::Application.routes.draw do
  root to: 'home#index'

  devise_for :users

  event_id = 5

  get 'fnf-tickets', controller: :ticket_requests, action: :new, event_id: event_id
  get 'fnf_tickets', controller: :ticket_requests, action: :new, event_id: event_id
  get 'fnftickets', controller: :ticket_requests, action: :new, event_id: event_id
  get 'fnf', controller: :ticket_requests, action: :new, event_id: event_id
  get 'FNF', controller: :ticket_requests, action: :new, event_id: event_id
  get 'FnF', controller: :ticket_requests, action: :new, event_id: event_id

  get 'eald', controller: :eald_payments, action: :new, event_id: event_id

  resources :payments, only: [:new, :create, :show] do
    collection do
      get :other
      post :sent
      post :mark_received
    end
  end

  resources :emails, only: :index

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
        post :revert_to_pending
      end
    end

    resources :eald_payments, only: [:index, :new, :create] do
      collection do
        get :complete
        get :download
      end
    end
  end

  resources :passwords, only: [] do
    collection do
      get :reset
    end
  end

  resources :site_admins, only: [:index, :new, :create, :destroy]
end
