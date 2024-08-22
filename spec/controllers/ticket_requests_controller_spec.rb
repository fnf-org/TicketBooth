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

    context 'when payments exist' do
      let(:viewer) { create(:site_admin).user }
      let(:payment1) { create(:payment, status: :in_progress, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request: ticket_requests[0]) }
      let(:payment2) { create(:payment, status: :received, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request: ticket_requests[1]) }
      let(:payment3) { create(:payment, status: :refunded, stripe_payment_id: 'pi_3PF4524ofUrW5ZY40NeGThOz', ticket_request: ticket_requests[2]) }

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

    subject { get :new, params: { event_id: event.id } }

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
    let(:event) { create(:event, tickets_require_approval: true, slug: 'created-event') }

    let(:ticket_request_params) { build(:ticket_request, event:).as_json }

    let(:post_params) { { event_id: event.id, ticket_request: ticket_request_params } }

    let(:make_request) do
      lambda { |params = {}|
        post_params.merge!(params) unless params.empty?
        post :create, params: post_params
      }
    end

    describe 'ticket_request_params' do
      subject { ticket_request_params }

      it { is_expected.to be_a(Hash) }
      it { is_expected.to include('event_id' => event.id) }
      it { is_expected.not_to include('ticket_request' => ['status']) }
    end

    context 'when event ticket sales are closed' do
      let(:viewer) { create(:user) }

      it 'has no error message before the request' do
        Timecop.freeze(event.end_time + 1.hour) do
          make_request[]
          expect(response).to redirect_to(attend_event_path(event))
          expect(flash.now[:error]).to_not be_nil
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
      before { make_request.call }

      let(:viewer) { nil }

      it { expect(response).to have_http_status(:redirect) }

      it { expect(flash.now[:error]).to be_nil }

      it 'not log the user in' do
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:ticket_request) { create(:ticket_request, event:, user:) }
    let(:ticket_request_id) { ticket_request.id }

    subject { delete_request_proc[ticket_request] }

    let(:delete_request_proc) do
      lambda do |ticket_request|
        delete :destroy, params: { event_id: ticket_request.event.to_param,
                                   id:       ticket_request.to_param }
      end
    end

    context 'attempt to delete when not allowed' do
      context 'when viewer not signed in' do
        it 'has no logged in user' do
          expect(controller.current_user).to be_nil
        end

        it { succeeds }

        it 'should not be cancellable' do
          expect(ticket_request.can_be_cancelled?(by_user: viewer)).to be_falsey
        end
      end

      context 'when viewer is not a ticket request owner' do
        let(:viewer) { create(:user) }

        it 'logged in user is not the same user as the ticket_request owner' do
          expect(controller.current_user).not_to be_nil
          expect(controller.current_user).to eql(viewer)
          expect(controller.current_user).not_to eql(ticket_request.user)
        end

        it { succeeds }

        it 'should not be cancellable' do
          expect(ticket_request.can_be_cancelled?(by_user: viewer)).to be_falsey
        end
      end
    end

    context 'delete when either event admin, site admin, or ticket request owner' do
      let(:ticket_request_from_db_proc) { ->(id) { TicketRequest.where(id:).first } }

      shared_examples_for 'successful deletion of the ticket request' do
        before { sign_in(viewer) }

        subject { delete_request_proc[ticket_request] }

        it { is_expected.to redirect_to(new_event_ticket_request_path(event)) }

        describe 'deleted ticket request should not exist' do
          subject { ticket_request_from_db_proc[ticket_request.id] }

          before { delete_request_proc[ticket_request] }

          it { is_expected.to be_nil }
        end
      end

      context 'when viewer is the event admin' do
        let(:viewer) { create(:event_admin, event:).user }

        it_behaves_like 'successful deletion of the ticket request'
      end

      context 'when viewer is a site admin' do
        let(:viewer) { create(:user, :site_admin) }

        it_behaves_like 'successful deletion of the ticket request'
      end

      context 'when viewer is ticket request owner' do
        let(:viewer) { ticket_request.user }

        it_behaves_like 'successful deletion of the ticket request'
      end
    end
  end
end
# rubocop: enable RSpec
