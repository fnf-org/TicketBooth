# frozen_string_literal: true

require 'rails_helper'

describe PaymentsController, type: :controller do
  let(:event) { create(:event, max_adult_tickets_per_request: 1) }
  let(:user) { create(:user) }
  let(:ticket_request) { create(:ticket_request, event:, user:, kids: 0) }
  let(:payment) { create(:payment, status: :in_progress, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request:) }

  before { sign_in user if user }

  describe 'POST #confirm' do
    subject { post :confirm, params: { id: payment.id, event_id: ticket_request.event.id, ticket_request_id: ticket_request.id } }

    context 'when payment status in progress' do
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when payment status new' do
      let(:payment) { create(:payment, status: :new, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when payment status received' do
      let(:payment) { create(:payment, status: :received, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when no stripe payment exists' do
      let(:payment) { create(:payment, status: :received, stripe_payment_id: nil, ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when provider is not stripe' do
      let(:payment) { create(:payment, provider: :other, status: :received, ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe 'GET #show' do
    subject { get :show, params: { id: payment.id, event_id: ticket_request.event.to_param, ticket_request_id: ticket_request.id } }

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

  describe 'GET #new' do
    subject do
      get :new, params: {
        id:                payment.id,
        event_id:          ticket_request.event.to_param,
        ticket_request_id: ticket_request.id
      }
    end

    context 'when user is signed in and owns the ticket request' do
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe 'GET #other' do
    subject do
      get :other, params: {
        id:                payment.id,
        event_id:          ticket_request.event.to_param,
        ticket_request_id: ticket_request.id
      }
    end

    context 'when user is signed in and owns the ticket request' do
      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'POST #sent' do
    subject do
      post :sent, params: {
        event_id:          ticket_request.event.to_param,
        ticket_request_id: ticket_request.id,
        explanation:       'Payment sent via Venmo'
      }
    end

    context 'when user is the ticket request owner' do
      # Ensure payment exists before the request
      before { payment }

      it { is_expected.to have_http_status(:redirect) }

      it 'sets the payment explanation' do
        subject
        expect(payment.reload.explanation).to eq 'Payment sent via Venmo'
      end

      it 'sets the provider to other' do
        subject
        expect(payment.reload).to be_provider_other
      end

      it 'sets the status to in_progress' do
        subject
        expect(payment.reload).to be_status_in_progress
      end
    end
  end

  describe 'POST #manual_confirmation' do
    subject do
      post :manual_confirmation, params: {
        event_id:          ticket_request.event.to_param,
        ticket_request_id: ticket_request.id
      }
    end

    context 'when user is the ticket request owner' do
      # Use a non-stripe provider payment to avoid Stripe API calls during cancel
      let(:payment) { create(:payment, status: :in_progress, provider: :other, stripe_payment_id: nil, ticket_request:) }

      before { payment }

      it { is_expected.to have_http_status(:redirect) }

      it 'marks the payment as received' do
        subject
        expect(payment.reload).to be_status_received
      end

      it 'marks the ticket request as completed' do
        subject
        expect(ticket_request.reload).to be_completed
      end

      it 'sets explanation to Marked Received' do
        subject
        expect(payment.reload.explanation).to eq 'Marked Received'
      end
    end
  end

  describe 'POST #create' do
    subject do
      post :create, params: {
        event_id:          ticket_request.event.to_param,
        ticket_request_id: ticket_request.id
      }, format: :json
    end

    context 'when the payment intent can be created', :vcr do
      it { is_expected.to have_http_status(:ok) }

      it 'returns JSON with clientSecret' do
        subject
        body = JSON.parse(response.body)
        expect(body).to have_key('clientSecret')
      end
    end
  end

  describe 'GET #index' do
    context 'when requesting via GET' do
      subject do
        get :index, params: {
          event_id:          ticket_request.event.to_param,
          ticket_request_id: ticket_request.id
        }
      end

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe '#validate_payment' do
    context 'when ticket request is already completed' do
      subject do
        get :show, params: {
          id:                payment.id,
          event_id:          ticket_request.event.to_param,
          ticket_request_id: ticket_request.id
        }
      end

      let(:ticket_request) { create(:ticket_request, :completed, event:, user:, kids: 0) }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when guests are not fully specified' do
      subject do
        get :show, params: {
          id:                payment.id,
          event_id:          ticket_request.event.to_param,
          ticket_request_id: ticket_request.id
        }
      end

      let(:ticket_request) { create(:ticket_request, event:, user:, kids: 0, adults: 3, guests: []) }

      it { is_expected.to have_http_status(:redirect) }
    end
  end
end
