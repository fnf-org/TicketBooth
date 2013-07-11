class ApplicationController < ActionController::Base
  force_ssl

  protect_from_forgery

protected

  def require_site_admin
    unless current_user.site_admin?
      redirect_to root_path
    end
  end

  def require_event_admin
    redirect_to :root unless @event.admin?(current_user)
  end
end
