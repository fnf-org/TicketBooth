# frozen_string_literal: true

require 'rails_helper'

describe TicketRequestsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:event) { create(:event) }

  let(:viewer) { nil }

  before { sign_in viewer if viewer }

  describe 'GET #index' do
    subject { get(:index, params: { event_id: event.to_param }) }

    let(:ticket_requests) { create_list(:ticket_request, event:, count: 3) }

    context 'when viewer not signed in' do
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when viewer is a normal user' do
      let(:viewer) { create(:user) }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when viewer is the event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when viewer is a site admin' do
      let(:viewer) { create(:site_admin).user }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'GET #show' do
    subject do
      get :show, params: { event_id: ticket_request.event.to_param,
                           id: ticket_request.to_param }
    end

    let(:ticket_request) { create(:ticket_request, user:) }

    context 'when viewer not signed in' do
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when viewer is not the owner of the ticket request' do
      let(:viewer) { create(:user) }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when viewer is the owner of the ticket request' do
      let(:viewer) { user }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event: ticket_request.event).user }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when viewer is a site admin' do
      let(:viewer) { create(:site_admin).user }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'GET #new' do
    let(:event) { create(:event) }

    before { get :new, params: { event_id: event.to_param } }

    context 'when viewer not signed in' do
      it { succeeds }
    end

    context 'when viewer signed in' do
      let(:viewer) { create(:user) }

      it { succeeds }
    end
  end

  describe 'GET #edit' do
    subject do
      get :edit, params: { event_id: ticket_request.event.to_param,
                           id: ticket_request.to_param }
    end

    let(:ticket_request) { create(:ticket_request, event:) }
    let(:user) { ticket_request.user }

    context 'when viewer not signed in' do
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when viewer is not owner of the ticket request' do
      let(:viewer) { create(:user) }

      it { is_expected.to redirect_to(new_event_ticket_request_path(ticket_request.event)) }
    end

    context 'when viewer is owner of the ticket request' do
      let(:viewer) { user }

      it { succeeds }
    end

    context 'when viewer is the event admin' do
      let(:viewer) { create(:event_admin, event: ticket_request.event).user }

      it { succeeds }
    end

    context 'when viewer is a site admin' do
      let(:viewer) { create(:site_admin).user }

      it { succeeds }
    end
  end

  describe 'POST #create' do
    let(:make_request) { ->(params = {}) { post :create, params: { event_id: event.id, ticket_request: ticket_request_params.merge(params) } } }

    let(:ticket_request_params) { build(:ticket_request, event:).as_json }

    it 'has a ticket request hash' do
      expect(ticket_request_params).to be_a(Hash)
    end

    context 'when event ticket sales are closed' do
      it 'has no error message before the request' do
        Timecop.freeze(event.end_time + 1.hour) do
          make_request.call
          expect(flash[:error]).to be('Sorry, but ticket sales have closed')
        end
      end
    end

    context 'when viewer already signed in' do
      subject(:response) { make_request[user_id: viewer.id] }

      let(:viewer) { create(:user) }

      it 'creates a ticket request' do
        expect { response }.to(change(TicketRequest, :count))
      end

      it 'assigned the ticket request to the viewer' do
        expect { subject }.to change { viewer.reload.reload.ticket_requests }.by(1)
      end
    end

    context 'when viewer is not signed in' do
      let(:email) { Faker::Internet.email }
      let(:password) { Faker::Internet.password }

      let(:user_attributes) do
        {
          name: Faker::Name.name,
          email:,
          password:
        }
      end

      let(:valid_params) { { event_id: event.to_param, user_attributes: } }

      describe '#create' do
        subject { make_request[user_attributes:] }

        let(:users_request_count) { -> { User.find_by(email:).ticket_requests.count } }

        its(:current_user) { is_expected.not_to be_nil }

        it 'creates a ticket request' do
          expect { subject }.to have_changed(TicketRequest, :count).by(1)
        end

        it 'assigns the ticket request to the created user' do
          expect(users_request_count[]).to be(1)
        end

        it 'signs in the created user' do
          expect(controller.current_user).to eql(User.find_by(email:))
        end
      end

      it 'creates a user with the specified email address' do
        User.find_by(email:).should_not be_nil
      end
    end
  end
end
