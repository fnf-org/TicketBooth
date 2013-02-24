require 'spec_helper'

describe "ticket_requests/index.html.erb" do
  before(:each) do
    assign(:ticket_requests, [
      stub_model(TicketRequest,
        :name => "Name",
        :email => "Email",
        :address => "Address",
        :cabins => 1,
        :adults => 1,
        :kids => 1
      ),
      stub_model(TicketRequest,
        :name => "Name",
        :email => "Email",
        :address => "Address",
        :cabins => 1,
        :adults => 1,
        :kids => 1
      )
    ])
  end

  it "renders a list of ticket_requests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Email".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
