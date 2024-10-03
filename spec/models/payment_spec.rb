# frozen_string_literal: true

# == Schema Information
#
# Table name: payments
#
#  id                :bigint           not null, primary key
#  explanation       :string
#  old_status        :string(1)        default("N"), not null
#  provider          :enum             default("stripe"), not null
#  status            :enum             default("new"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stripe_charge_id  :string(255)
#  stripe_payment_id :string
#  stripe_refund_id  :string
#  ticket_request_id :integer          not null
#
# Indexes
#
#  index_payments_on_stripe_payment_id  (stripe_payment_id)
#

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
        let(:payment) { build(:payment, status: 'in_progress') }

        it { is_expected.to be_valid }
      end

      context 'when unknown status' do
        let(:payment) { build(:payment) }

        it 'is not valid to set to unknown status' do
          expect { payment.status = 'nope' }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'provider' do
      context 'with stripe' do
        let(:payment) { build(:payment, provider: 'stripe') }

        it { is_expected.to be_valid }

        it 'has provider of stripe' do
          expect(payment.provider).to eq('stripe')
        end

        it 'has prefix predicate for stripe' do
          expect(payment).to be_provider_stripe
        end
      end

      context 'with other provider' do
        let(:payment) { build(:payment, provider: 'other') }

        it { is_expected.to be_valid }

        it 'has provider of other' do
          expect(payment.provider).to eq('other')
        end

        it 'has prefix predicate for other' do
          expect(payment).to be_provider_other
        end
      end

      context 'when unknown provider' do
        let(:payment) { build(:payment) }

        it 'is not valid to set to unknown provider' do
          expect { payment.provider = 'nope' }.to raise_error(ArgumentError)
        end
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

  describe 'save_with_payment_intent' do
    subject(:payment_intent) { payment.save_with_payment_intent }

    let(:payment) { build(:payment) }

    it { is_expected.to be_a(Stripe::PaymentIntent) }

    it 'changes the payment status', :vcr do
      expect { payment_intent }.to(change(payment, :status).to('in_progress'))
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
      it 'raises Stripe error when amount < 50 cents', :vcr do
        expect { payment.create_payment_intent(1) }.to raise_error(Stripe::InvalidRequestError)
      end
    end
  end

  describe '#cancel_payment_intent' do
    let(:amount) { 1000 }
    let(:payment) { build(:payment, provider: :stripe, status: :in_progress) }

    describe 'cancel valid payment intent' do
      before do
        payment_intent = payment.create_payment_intent(amount)
        payment.stripe_payment_id = payment_intent.id
      end

      it 'returns a PaymentIntent', :vcr do
        expect(payment.cancel_payment_intent).to be_a(Stripe::PaymentIntent)
      end

      it 'has payment intent canceled_at set', :vcr do
        payment.cancel_payment_intent
        expect(payment.payment_intent['canceled_at']).not_to be_nil
      end
    end

    describe 'invalid payment state' do
      it 'does not cancel if stripe_payment_id not present' do
        payment.stripe_payment_id = nil
        expect(payment.cancel_payment_intent).to be_nil
      end

      it 'does not cancel if status not in progress' do
        payment.status_refunded!
        expect(payment.cancel_payment_intent).to be_nil
      end

      it 'does not cancel if not stripe payment' do
        payment.provider_cash!
        expect(payment.cancel_payment_intent).to be_nil
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

  describe 'retrieve_or_save_payment_intent' do
    subject(:payment_intent) { payment.retrieve_or_save_payment_intent }

    let(:amount) { 1000 }
    let(:payment) { build(:payment, stripe_payment_id: nil) }

    it { is_expected.to be_a(Stripe::PaymentIntent) }

    it 'changes payment status' do
      expect { payment_intent }.to(change(payment, :status).to('in_progress'))
    end

    context 'when stripe payment exists' do
      before { payment.save_with_payment_intent }

      it 'does not chanmge stripe payment id when it exists' do
        expect { payment_intent }.not_to(change(payment, :stripe_payment_id))
      end

      it 'does not change payment intent' do
        expect { payment_intent }.not_to(change(payment, :payment_intent))
      end
    end
  end

  describe 'refunds' do
    describe '#stripe_payment?' do
      subject { payment.stripe_payment? }

      let(:payment) { build(:payment) }

      it { is_expected.to be_truthy }
    end

    describe '#refunded?' do
      subject { payment.refunded? }

      let(:payment) { build(:payment, status: 'refunded', stripe_refund_id: 'refundId') }

      it { is_expected.to be_truthy }

      context 'when payment not refunded' do
        let(:payment) { build(:payment, status: 'received') }

        it { is_expected.to be_falsey }
      end
    end

    describe '#refundable?' do
      subject { payment.refundable? }

      let(:payment) { build(:payment, status: 'received', stripe_refund_id: nil) }

      it { is_expected.to be_truthy }

      context 'when payment already refunded' do
        let(:payment) { build(:payment, status: 'refunded', stripe_refund_id: 'refundId') }

        it { is_expected.to be_falsey }
      end

      context 'when payment is nil' do
        let(:payment) { nil }

        it 'returns false when payment is nil' do
          expect(payment&.refundable?).to be_falsey
        end
      end
    end
  end
end
