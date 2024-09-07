# frozen_string_literal: true

require 'colorize'

# General controller configuration and helpers.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Allow user to log in via authentication token
  before_action :authenticate_user_from_token!

  # Allow additional parameters to be passed to Devise-managed controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

  # By default, enable friendly forwarding if user is logged in
  before_action :redirect_path, unless: :user_signed_in?

  add_flash_types :info, :error, :warning

  protected

  def site_host
    Rails.application.config.action_mailer.default_url_options[:host]
  end

  def site_url
    request.ssl? ? "https://#{site_host}" : "http://#{site_host}"
  end

  def stripe_publishable_api_key
    @stripe_publishable_api_key ||= Rails.configuration.stripe[:publishable_api_key]
  end

  def set_event
    Rails.logger.debug { "#set_event() permitted params: #{permitted_params.inspect}" }

    event_id = permitted_params[:event_id].to_i
    Rails.logger.debug { "#set_event() => event_id = #{event_id}, params[:event_id] => #{permitted_params[:event_id]}" }

    event_not_found = lambda do |eid, flash|
      flash.now[:error] = "Event with id #{eid} was not found."
      redirect_to root_path
    end

    @event = Event.where(id: event_id).first
    event_not_found[event_id, flash] if @event.nil?
  end

  def ticket_request_id
    nil
  end

  def set_ticket_request
    Rails.logger.debug { "#set_ticket_request() => ticket_request_id = #{ticket_request_id}" }
    return unless ticket_request_id

    # check if ticket request exists
    @ticket_request = TicketRequest.find_by(id: ticket_request_id)
    if @ticket_request.blank?
      Rails.logger.info { "#set_ticket_request() => unknown ticket_request_id: #{ticket_request_id}" }
      return redirect_to root_path
    end

    Rails.logger.debug { "#set_ticket_request() => @ticket_request = #{@ticket_request&.inspect}" }

    redirect_to @event unless @ticket_request.event == @event
  end

  # Override a Devise method
  def after_sign_in_path_for(resource)
    if redirect_to_param.present?
      store_location_for(resource, redirect_to_param)
    elsif [Routing.routes.new_user_registration_url,
           Routing.routes.new_user_session_url].include?(request.referer)
      super
    else
      stored_location_for(resource) || root_path
    end
  end

  def redirect_path
    @redirect_path = redirect_to_param || root_path
  end

  def redirect_to_param
    @redirect_to_param ||= params.permit(:redirect_to)[:redirect_to]
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
    permitted_attributes = %i[email password password_confirmation current_password first last redirect_to]
    devise_parameter_sanitizer.permit(:sign_up) { |user| user.permit(*permitted_attributes) }
    devise_parameter_sanitizer.permit(:account_update) { |user| user.permit(*permitted_attributes) }
  end

  def authenticate_user_from_token!
    Rails.logger.debug { "#authenticate_user_from_token!() params: #{params.inspect}" }

    if params[:user_id].present?
      user_id = convert_int_param_safely(params[:user_id])
      user = User.find_by(id: user_id)
      Rails.logger.debug { "#authenticate_user_from_token!() user_id: #{user_id} user #{user}" }

    elsif params[:user_token].present?
      user = User.find_by(authentication_token: params[:user_token])
      Rails.logger.debug { "#authenticate_user_from_token!() user_token: #{params[:user_token]} user #{user}" }
    end

    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
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

  def alert_log_color(alert_type)
    case alert_type
    when 'notice' then :blue
    when 'error', 'alert' then :red
    when 'warning' then :yellow
    else :green
    end
  end

  def render_flash(flash)
    flash.each do |type, msg|
      log_level = alert_log_level(type) || :error
      color = alert_log_color(type)
      msg = msg.colorize(color).colorize(:bold) if color
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

  def convert_int_param_safely(str)
    Integer(str)
  rescue StandardError
    nil
  end
end
