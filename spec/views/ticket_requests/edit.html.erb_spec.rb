require 'spec_helper'

describe "ticket_requests/edit.html.erb" do
  before(:each) do
    @ticket_request = assign(:ticket_request, stub_model(TicketRequest,
      :name => "MyString",
      :email => "MyString",
      :address => "MyString",
      :cabins => 1,
      :adults => 1,
      :kids => 1
    ))
  end

  it "renders the edit ticket_request form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => ticket_requests_path(@ticket_request), :method => "post" do
      assert_select "input#ticket_request_name", :name => "ticket_request[name]"
      assert_select "input#ticket_request_email", :name => "ticket_request[email]"
      assert_select "input#ticket_request_address", :name => "ticket_request[address]"
      assert_select "input#ticket_request_cabins", :name => "ticket_request[cabins]"
      assert_select "input#ticket_request_adults", :name => "ticket_request[adults]"
      assert_select "input#ticket_request_kids", :name => "ticket_request[kids]"
    end
  end
end
