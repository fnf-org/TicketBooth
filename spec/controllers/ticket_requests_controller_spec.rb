require 'spec_helper'

describe TicketRequestsController do
  describe 'GET #show' do
    let(:viewer) { nil }
    let(:user) { User.make! }
    let(:ticket_request) { TicketRequest.make! user: user }

    before do
      sign_in viewer if viewer
      get :show, event_id: ticket_request.event.to_param,
                 id: ticket_request.to_param
    end

    context 'when the viewer is not logged in' do
      it 'redirects to the login page' do
        response.should be_redirect
      end
    end

    context 'when the viewer is not the owner of the ticket request' do
      let(:viewer) { User.make! }

      it 'redirects' do
        response.should redirect_to root_path
      end
    end

    context 'when the viewer is the owner of the ticket request' do
      let(:viewer) { user }

      it 'succeeds' do
        response.should be_success
      end
    end

    context 'when the viewer is an event admin' do
      let(:viewer) { EventAdmin.make!(event: ticket_request.event).user }

      it 'succeeds' do
        response.should be_success
      end
    end

    context 'when the viewer is a site admin' do
      let(:viewer) { User.make! :site_admin }

      it 'succeeds' do
        response.should be_success
      end
    end
  end
end
