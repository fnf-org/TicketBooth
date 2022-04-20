# frozen_string_literal: true

require 'spec_helper'

describe PaymentMailer do
  let(:user) { User.make! }
  let(:event) { Event.make! name: 'Test Event' }

  let(:ticket_request) do
    TicketRequest.make! event: event,
                        user: user
  end

  let(:payment) { Payment.make! ticket_request: ticket_request }

  describe '#payment_received' do
    let(:mail) { described_class.payment_received(payment) }

    it 'renders the subject' do
      mail.subject.should == 'Your payment for Test Event has been received'
    end

    it 'sends to the owner of the ticket request' do
      mail.to.should == [user.email]
    end

    it "includes the user's name" do
      mail.body.encoded.should match(user.first_name)
    end

    it "includes the event's name" do
      mail.body.encoded.should match('Test Event')
    end
  end
end
