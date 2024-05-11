# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                :integer          not null, primary key
#  explanation       :string(255)
#  status            :string(1)        default("P"), not null
#  created_at        :datetime
#  updated_at        :datetime
#  stripe_charge_id  :string(255)
#  ticket_request_id :integer          not null

require 'rails_helper'

describe Payment do
  describe 'validations' do
    subject { payment }

    describe '#ticket_request' do
      let(:payment) { build(:payment, ticket_request:) }

      context 'when not present' do
        let(:ticket_request) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when present' do
        let(:ticket_request) { build(:ticket_request) }

        it { is_expected.to be_valid }
      end
    end

    describe '#status' do
      context 'when in progress' do
        let(:payment) { build(:payment, status: Payment::STATUS_IN_PROGRESS) }

        it { is_expected.to be_valid }
      end

      context 'when unknown status' do
        let(:payment) { build(:payment, status: 'nope') }

        it { is_expected.not_to be_valid }
      end

      context 'when not present' do
        let(:payment) { build(:payment, status: nil) }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe '#cost' do
    let(:event) { build(:event, adult_ticket_price: 100) }
    let(:ticket_request) do
      build(:ticket_request, event:, adults: 1, kids: 0)
    end

    let(:payment) { build(:payment, ticket_request:) }

    describe 'calculate_cost' do
      subject { payment.calculate_cost }

      it { is_expected.to be(10_000) }
    end

    describe 'dollar_cost' do
      subject { payment.dollar_cost }

      it { is_expected.to be(100) }
    end
  end

  describe 'payment intent' do
    subject { payment.save_with_payment_intent }

    let(:payment) { build(:payment) }

    describe 'valid payment intent' do
      it { is_expected.to be_truthy }
    end

    describe 'status' do
      subject { payment.save_with_payment_intent.status }

      it { is_expected.to eq(Payment::STATUS_IN_PROGRESS) }
    end

    describe 'payment intent' do
      subject { payment.save_with_payment_intent.payment_intent.id }

      it { is_expected.to be_truthy }

      it { is_expected.to be_a(String) }
    end
  end

  describe '#create_payment_intent' do
    subject { payment.create_payment_intent(amount) }

    let(:amount) { 1000 }
    let(:payment) { build(:payment) }

    describe 'create payment intent' do
      it { is_expected.to be_a(Stripe::PaymentIntent) }
    end

    describe 'stripe failure' do
      it 'raises Stripe error when amount < 50 cents' do
        expect { payment.create_payment_intent(1) }.to raise_error(Stripe::InvalidRequestError)
      end
    end
  end

  describe '#retrieve_payment_intent' do
    subject { payment.create_payment_intent(amount) }

    let(:amount) { 1000 }
    let(:payment_intent) { payment.retrieve_payment_intent }
    let(:payment) { build(:payment) }

    it { is_expected.to be_a(Stripe::PaymentIntent) }
  end
end