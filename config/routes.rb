# frozen_string_literal: true

# rubocop: disable Metrics/BlockLength
Rails.application.routes.draw do
  root 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'oops', controller: :home, action: :oops

  devise_scope :user do
    # Redirests signing out users back to sign-in
    get 'users', to: 'devise/sessions#new'
  end

  devise_for :users

  # WTF was this for? --@kig
  #
  # event_id = 9
  #
  # get('fnf-tickets', controller: :ticket_requests, action: :new, event_id:)
  # get('fnf_tickets', controller: :ticket_requests, action: :new, event_id:)
  # get('fnftickets', controller: :ticket_requests, action: :new, event_id:)
  # get('fnf', controller: :ticket_requests, action: :new, event_id:)
  # get('FNF', controller: :ticket_requests, action: :new, event_id:)
  # get('FnF', controller: :ticket_requests, action: :new, event_id:)
  #
  # get('eald', controller: :eald_payments, action: :new, event_id:)

  resources :payments, only: %i[new create show] do
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
      get :download_guest_list
    end

    resources :jobs do
      resources :time_slots, only: %i[new create edit update destroy]
    end

    resources :shifts, only: %i[index create destroy]

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

    resources :eald_payments, only: %i[index new create] do
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
  resources :site_admins, only: %i[index new create destroy]

  get '/tickets/request/:event_id', to: 'ticket_requests#new', as: :tickets_request
end
# rubocop: enable Metrics/BlockLength
