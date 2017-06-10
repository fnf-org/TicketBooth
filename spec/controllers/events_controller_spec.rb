require 'spec_helper'

describe EventsController, type: :controller do
  let(:event) { Event.make! }
  let(:viewer) { nil }
  before { sign_in viewer if viewer }

  describe 'GET #show' do
    before { get :show, id: event.to_param }

    context 'when the user is not signed in' do
      it { redirects_to new_event_ticket_request_path(event) }
    end

    context 'when the user is signed in' do
      context 'and is not an event admin' do
        let(:viewer) { User.make! }
        it { redirects_to new_event_ticket_request_path(event) }
      end

      context 'and is an event admin' do
        let(:viewer) { EventAdmin.make!(event: event, user: User.make!).user }
        it { succeeds }
      end
    end
  end
end
