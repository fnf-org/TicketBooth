class ApplicationController < ActionController::Base
  protect_from_forgery

protected

  def require_site_admin
    redirect_to root_path unless current_user.site_admin?
  end

  def require_event_admin
    redirect_to :root unless @event.admin?(current_user)
  end
end
