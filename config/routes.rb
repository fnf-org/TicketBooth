# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'oops', controller: :home, action: :oops

  # devise_scope :user do
  #   # Redirects signing out users back to sign-in
  #   get 'users', to: 'devise/sessions#new'
  # end

  devise_for :users

  resources :emails, only: :index

  resources :events do
    member do
      post :add_admin
      post :remove_admin
      get :guest_list
      get :active_ticket_requests
      get :download_guest_list
      get :active_addons_passes
      get :active_addons_camping
    end

    resources :jobs do
      resources :time_slots, only: %i[new create edit update destroy]
    end

    resources :shifts, only: %i[index create destroy]

    resources :ticket_requests do
      collection do
        post :download
        post :payment_reminder
        post :email_ticket_holders
      end

      member do
        patch :update
        delete :destroy
        post :approve
        post :decline
        post :refund
        post :resend_approval
        post :revert_to_pending
      end

      resources :payments do
        collection do
          get :confirm
          post :sent
          post :manual_confirmation
        end

        member do
          get :new
          post :create
          get :show
          get :other
        end
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
  get '/attend/:event_id', to: 'ticket_requests#new', as: :attend_event
end
