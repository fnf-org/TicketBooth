# frozen_string_literal: true

# General controller configuration and helpers.
class ApplicationController < ActionController::Base
  protect_from_forgery

  # Allow user to log in via authentication token
  before_action :authenticate_user_from_token!

  # Allow additional parameters to be passed to Devise-managed controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def require_site_admin
    redirect_to root_path unless current_user.site_admin?
  end

  def require_event_admin
    redirect_to new_event_ticket_request_path(@event) unless @event.admin?(current_user)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def authenticate_user_from_token!
    user_id = params[:user_id].presence
    user    = User.find_by_id(user_id)

    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      user.update_attribute(:authentication_token, nil) # One-time use
      sign_in user
    end
  end

  # This is so that RubyMine can find it
  # rubocop: disable Lint/UselessMethodDefinition
  def current_user
    super
  end
end
