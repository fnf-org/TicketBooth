require "spec_helper"

describe SiteAdminsController do
  describe "routing" do

    it "routes to #index" do
      get("/site_admins").should route_to("site_admins#index")
    end

    it "routes to #new" do
      get("/site_admins/new").should route_to("site_admins#new")
    end

    it "routes to #show" do
      get("/site_admins/1").should route_to("site_admins#show", :id => "1")
    end

    it "routes to #edit" do
      get("/site_admins/1/edit").should route_to("site_admins#edit", :id => "1")
    end

    it "routes to #create" do
      post("/site_admins").should route_to("site_admins#create")
    end

    it "routes to #update" do
      put("/site_admins/1").should route_to("site_admins#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/site_admins/1").should route_to("site_admins#destroy", :id => "1")
    end

  end
end
