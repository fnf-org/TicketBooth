class ApplicationController < ActionController::Base
  protect_from_forgery

  # Allow additional parameters to be passed to Devise-managed controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

protected

  def require_site_admin
    redirect_to root_path unless current_user.site_admin?
  end

  def require_event_admin
    redirect_to :root unless @event.admin?(current_user)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end
end
