require "spec_helper"

describe TicketRequestsController do
  describe "routing" do

    it "routes to #index" do
      get("/ticket_requests").should route_to("ticket_requests#index")
    end

    it "routes to #new" do
      get("/ticket_requests/new").should route_to("ticket_requests#new")
    end

    it "routes to #show" do
      get("/ticket_requests/1").should route_to("ticket_requests#show", :id => "1")
    end

    it "routes to #edit" do
      get("/ticket_requests/1/edit").should route_to("ticket_requests#edit", :id => "1")
    end

    it "routes to #create" do
      post("/ticket_requests").should route_to("ticket_requests#create")
    end

    it "routes to #update" do
      put("/ticket_requests/1").should route_to("ticket_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/ticket_requests/1").should route_to("ticket_requests#destroy", :id => "1")
    end

  end
end
