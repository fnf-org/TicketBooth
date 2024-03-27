# frozen_string_literal: true

require 'rails_helper'

describe EaldPaymentMailer do
  let(:payment) { create(:eald_payment) }
  let(:event) { payment.event }

  describe '#eald_payment_received' do
    subject(:mail) { described_class.eald_payment_received(payment) }

    let(:expected_subject) { "Your payment for #{event.name} Early Arrival/Late Departure passes has been received" }

    its(:subject) { is_expected.to eql(expected_subject) }

    its(:to) { is_expected.to eql([payment.email]) }

    its('body.encoded') { is_expected.to match(event.name) }
  end
end
