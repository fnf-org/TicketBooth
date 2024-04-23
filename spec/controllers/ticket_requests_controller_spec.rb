# frozen_string_literal: true

require 'rails_helper'

# rubocop: disable RSpec
describe TicketRequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

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
                           id:       ticket_request.to_param }
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

    before { get :new, params: { event_id: event } }

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
                           id:       ticket_request.to_param }
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
    let(:event) { create(:event, tickets_require_approval: true) }

    let(:ticket_request_params) { build(:ticket_request, event:).as_json }

    let(:post_params) { { event_id: event.id, ticket_request: ticket_request_params } }

    let(:make_request) do
      lambda { |params = {}|
        post_params.merge!(params) unless params.empty?
        post :create, params: post_params
      }
    end

    describe 'without Ventable callbacks', :ventable_disabled do
      describe 'ticket_request_params' do
        subject { ticket_request_params }

        it { is_expected.to be_a(Hash) }
        it { is_expected.to include('event_id' => event.id) }
        it { is_expected.not_to include('ticket_request' => ['status']) }
      end

      context 'when event ticket sales are closed' do
        it 'has no error message before the request' do
          Timecop.freeze(event.end_time + 1.hour) do
            make_request.call
            expect(flash[:error]).to_not be_nil
          end
        end
      end

      context 'when viewer already signed in' do
        subject { make_request.call }

        let(:viewer) { user }

        before { TicketRequest.where(user_id: viewer.id).destroy_all }

        describe '#create HTTP status' do
          it { succeeds }

          it 'has no errors' do
            expect(flash[:error]).to be_nil
          end
        end

        describe 'database state' do
          subject(:response) { make_request[] }

          it 'creates a ticket request' do
            expect { subject }.to(change(TicketRequest, :count))
          end

          it 'assigned the ticket request to the viewer' do
            expect { subject }.to change { viewer.ticket_requests.count }.by(1)
          end
        end
      end

      context 'when viewer is not signed in' do
        subject { make_request[user_attributes] }

        let(:email) { Faker::Internet.email }
        let(:name) { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
        let(:password) { Faker::Internet.password }

        let(:user_attributes) do
          {
            name:,
            email:,
            password:,
            password_confirmation: password
          }
        end

        let(:created_user) { User.find_by(email:) }
        let(:users_request_count) { -> { created_user&.ticket_requests&.count } }

        it { succeeds }

        it 'has no errors' do
          expect(flash[:error]).to be_nil
        end

        describe 'ticket requests count' do
          describe 'user creation' do
            it 'creates a user' do
              expect { subject }.to change(User, :count).by(1)
            end
          end

          it 'creates a ticket request' do
            expect { subject }.to change(TicketRequest, :count).by(1)
          end

          it 'creates a user' do
            expect { subject }.to change(User, :count).by(1)
          end

          describe 'creates a ticket request that' do
            before { subject }
            it 'belongs to the created user' do
              expect(created_user.ticket_requests.count).to be(1)
            end
          end
        end

        describe '#current_user' do
          subject { controller&.current_user }

          before { make_request[user_attributes] }

          it { is_expected.not_to be_nil }

          it { is_expected.to eql(created_user) }
        end
      end
    end
  end
end
# rubocop: enable RSpec
