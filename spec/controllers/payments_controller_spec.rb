# frozen_string_literal: true

require 'rails_helper'

describe PaymentsController, type: :controller do
  let(:event) { create(:event, max_adult_tickets_per_request: 1) }
  let(:user) { create(:user, :confirmed) }
  let(:ticket_request) { create(:ticket_request, event:, user:, kids: 0) }
  let(:payment) { create(:payment, status: Payment::STATUS_IN_PROGRESS, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request:) }

  before { sign_in user if user }

  describe 'POST #confirm' do
    subject { post :confirm, params: { event_id: ticket_request.event.id, ticket_request_id: ticket_request.id, id: payment.id } }

    context 'when payment status in progress' do
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when payment status new' do
      let(:payment) { create(:payment, status: Payment::STATUS_NEW, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when payment status received' do
      let(:payment) { create(:payment, status: Payment::STATUS_RECEIVED, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when no stripe payment exists' do
      let(:payment) { create(:payment, status: Payment::STATUS_RECEIVED, stripe_payment_id: nil, ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe 'GET #show' do
    subject { get :show, params: { id: payment.id, event_id: ticket_request.event.id, ticket_request_id: ticket_request.id } }

    context 'when payment exists' do
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when viewer is not the owner of the ticket request' do
      let(:ticket_request) { create(:ticket_request) }
      let(:payment) { create(:payment, ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end

    describe '#validate payments' do
      context 'when ticket sales closes' do
        let(:event) { create(:event, max_adult_tickets_per_request: 1, ticket_sales_end_time: 1.week.ago) }

        it { is_expected.to have_http_status(:redirect) }
      end

      context 'when event has ended' do
        let(:event) { create(:event, max_adult_tickets_per_request: 1, start_time: 2.weeks.ago, end_time: 1.week.ago) }

        it { is_expected.to have_http_status(:redirect) }
      end
    end
  end
end
