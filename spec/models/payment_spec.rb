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
  end

  describe '#cost' do
    subject { payment.calculate_cost }

    describe 'cost' do
      let(:event) { build(:event, adult_ticket_price: 100) }
      let(:ticket_request) do
        build(:ticket_request, event: event, adults: 1, kids: 0)
      end
      let(:payment) { build(:payment, ticket_request:) }

      it { is_expected.to eql(10000) }
    end
  end

  describe '#create' do
    subject { payment.save_and_charge! }

    describe 'valid payment intent' do
      let(:payment) { build(:payment) }

      it { is_expected.to be_truthy }

    end

  end
end