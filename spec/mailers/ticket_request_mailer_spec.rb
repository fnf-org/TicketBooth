require 'spec_helper'

describe TicketRequestMailer do
  let(:user) { User.make! }
  let(:event) { Event.make! name: 'Test Event' }
  let(:ticket_request) { TicketRequest.make! event: event, user: user }

  describe '#request_received' do
    let(:mail) { described_class.request_received(ticket_request) }

    it 'renders the subject' do
      mail.subject.should == 'Test Event ticket request confirmation'
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it "includes the user's name" do
      mail.body.encoded.should match(user.first_name)
    end

    it "includes the event's name" do
      mail.body.encoded.should match('Test Event')
    end

    it "includes a link to the user's ticket request" do
      mail.body.encoded.should match(event_ticket_request_url(event, ticket_request))
    end
  end
end
