class SiteAdminsController < ApplicationController
  force_ssl

  before_filter :authenticate_user!
  before_filter :require_site_admin

  def index
    @site_admins = SiteAdmin.includes(:user).all
  end

  def new
    @site_admin = SiteAdmin.new
  end

  def create
    @site_admin = SiteAdmin.new(params[:site_admin])

    if @site_admin.save
      flash[:notice] = "#{@site_admin.user.name} is now a site admin."
      redirect_to site_admins_path
    else
      render action: 'new'
    end
  end

  def destroy
    @site_admin = SiteAdmin.find(params[:id])
    @site_admin.destroy

    redirect_to site_admins_url
  end
end
