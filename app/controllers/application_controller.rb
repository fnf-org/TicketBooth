class ApplicationController < ActionController::Base
  force_ssl
  protect_from_forgery

  def require_site_admin
    unless current_user.site_admin?
      redirect_to root_path
    end
  end
end
