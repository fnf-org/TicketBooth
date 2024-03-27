# frozen_string_literal: true

require 'rails_helper'

describe TicketRequestMailer do
  let(:user) { ticket_request.user }
  let(:event) { ticket_request.event }
  let(:ticket_request) { create(:ticket_request, special_price: price) }
  let(:price) { nil }

  describe '#request_received' do
    subject(:mail) { described_class.request_received(ticket_request) }

    its(:subject) { is_expected.to eql "#{event.name} ticket request confirmation" }

    its(:to) { is_expected.to eql [user.email] }

    its('body.encoded') { is_expected.to match(user.first_name) }

    its('body.encoded') { is_expected.to match(event.name) }
  end

  describe '#request_approved' do
    subject(:mail) { described_class.request_approved(ticket_request) }

    let(:body) { mail.body.encoded }

    its(:subject) { is_expected.to eq "Your #{event.name} ticket request has been approved!" }

    its(:to) { is_expected.to eq [user.email] }

    its(:body) { is_expected.to match(user.first_name) }

    its('body.decoded') { is_expected.to match(event.name) }

    context 'when the ticket request is free' do
      let(:price) { 0 }

      its(:body) { is_expected.to match("You're good to go!") }
    end

    context 'when the ticket request is not free' do
      let(:price) { 10 }

      its(:body) { is_expected.to match('purchase') }
    end
  end
end
