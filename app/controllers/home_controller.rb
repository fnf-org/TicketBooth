class HomeController < ApplicationController
  def index
    if signed_in? && current_user.site_admin?
      redirect_to events_path
    end
  end
end
