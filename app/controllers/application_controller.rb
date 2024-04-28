# frozen_string_literal: true

# General controller configuration and helpers.
class ApplicationController < ActionController::Base
  protect_from_forgery

  # Allow user to log in via authentication token
  before_action :authenticate_user_from_token!

  # Allow additional parameters to be passed to Devise-managed controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

  after_action :process_redirect

  add_flash_types :info, :error, :warning

  protected

  def process_redirect
    if params[:redirect_url] && response.successful?
      redirect_to params[:redirect_url]
    end
  end

  def require_site_admin
    redirect_to root_path unless current_user.site_admin?
  end

  def require_event_admin
    redirect_to new_event_ticket_request_path(@event) unless @event.admin?(current_user)
  end

  def require_logged_in_user
    unless current_user&.id
      redirect_to new_user_session_path
    end
  end

  def configure_permitted_parameters
    permitted_attributes = %i[email password password_confirmation first last redirect_url]
    devise_parameter_sanitizer.permit(:sign_up) { |user| user.permit(*permitted_attributes) }
    devise_parameter_sanitizer.permit(:account_update) { |user| user.permit(*permitted_attributes) }
  end

  def authenticate_user_from_token!
    user_id = params[:user_id].presence
    user    = user_id ? User.find_by(id: user_id) : nil

    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      user.update_attribute(:authentication_token, nil) # One-time use
      sign_in user
    end
  end

  def alert_log_level(alert_type)
    case alert_type
    when 'notice' then :info
    when 'error', 'alert' then :error
    when 'warning' then :warn
    else :debug
    end
  end

  def render_flash(flash)
    flash.each do |type, msg|
      log_level = alert_log_level(type) || :error
      Rails.logger.send(log_level, msg)
    end

    respond_to do |format|
      format.html do
        render partial: 'shared/flash', locals: { flash: }
      end
      format.turbo_stream do
        render turbo_stream: [turbo_stream.replace(:flash, partial: 'shared/flash', locals: { flash: })]
      end
    end
  end
end
