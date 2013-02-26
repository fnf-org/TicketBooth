class SiteAdminsController < ApplicationController
  def index
    @site_admins = SiteAdmin.includes(:user).all

    respond_to do |format|
      format.html
      format.json { render json: @site_admins }
    end
  end

  def new
    @site_admin = SiteAdmin.new

    respond_to do |format|
      format.html
      format.json { render json: @site_admin }
    end
  end

  def create
    @site_admin = SiteAdmin.new(params[:site_admin])

    respond_to do |format|
      if @site_admin.save
        format.html { redirect_to site_admins_path,
                        notice: "#{@site_admin.user.name} is now a site admin." }
        format.json { render json: @site_admin, status: :created, location: @site_admin }
      else
        format.html { render action: "new" }
        format.json { render json: @site_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @site_admin = SiteAdmin.find(params[:id])
    @site_admin.destroy

    respond_to do |format|
      format.html { redirect_to site_admins_url }
      format.json { head :no_content }
    end
  end
end
