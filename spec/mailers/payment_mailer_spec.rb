# frozen_string_literal: true

require 'rails_helper'

describe PaymentMailer do
  let(:ticket_request) { create(:ticket_request) }
  let(:user) { ticket_request.user }
  let(:event) { ticket_request.event }
  let(:payment) { create(:payment, ticket_request:) }

  describe '#payment_received' do
    subject(:mail) { described_class.payment_received(payment) }

    let(:expected_subject) { "Your payment for #{event.name} has been received" }

    its(:subject) { is_expected.to eql(expected_subject) }

    its(:to) { is_expected.to eql([user.email]) }

    its('body.encoded') { is_expected.to match(user.first_name) }

    its('body.encoded') { is_expected.to match(event.name) }
  end
end
