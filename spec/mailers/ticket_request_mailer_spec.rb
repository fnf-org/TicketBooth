# frozen_string_literal: true

require 'rails_helper'

describe TicketRequestMailer do
  let(:user) { User.make! }
  let(:event) { Event.make! name: 'Test Event' }
  let(:price) { nil }

  let(:ticket_request) do
    TicketRequest.make! event:,
                        user:,
                        special_price: price
  end

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
  end

  describe '#request_approved' do
    let(:mail) { described_class.request_approved(ticket_request) }
    let(:body) { mail.body.encoded }

    it 'renders the subject' do
      mail.subject.should == 'Your Test Event ticket request has been approved!'
    end

    it 'renders the receiver email' do
      mail.to.should == [user.email]
    end

    it "includes the user's name" do
      body.should match(user.first_name)
    end

    it "includes the event's name" do
      body.should match('Test Event')
    end

    context 'when the ticket request is free' do
      let(:price) { 0 }

      it 'includes the correct phrase' do
        body.should match("You're good to go!")
      end
    end

    context 'when the ticket request is not free' do
      let(:price) { 10 }

      it 'includes the word "purchase"' do
        body.should match('purchase')
      end
    end
  end
end
