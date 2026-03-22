# frozen_string_literal: true

require 'rails_helper'

describe TicketRequestsController, 'authorization', type: :controller do
  let(:event) { create(:event) }
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:event_admin, event:).user }
  let(:denied_path) { new_event_ticket_request_path(event) }

  describe 'POST #download' do
    context 'when a regular user (not event admin) attempts to download CSV' do
      before do
        sign_in regular_user
        post :download, params: { event_id: event.to_param, type: 'all' }
      end

      it 'denies access' do
        expect(response).to redirect_to(denied_path)
      end
    end

    context 'when an event admin downloads CSV' do
      before do
        sign_in admin_user
        post :download, params: { event_id: event.to_param, type: 'all' }
      end

      it 'allows access' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #payment_reminder' do
    context 'when a regular user attempts to send payment reminders' do
      before do
        sign_in regular_user
        post :payment_reminder, params: { event_id: event.to_param }
      end

      it 'denies access' do
        expect(response).to redirect_to(denied_path)
      end
    end
  end

  describe 'GET #email_ticket_holders' do
    context 'when a regular user attempts to email ticket holders' do
      before do
        sign_in regular_user
        get :email_ticket_holders, params: { event_id: event.to_param }
      end

      it 'denies access' do
        expect(response).to redirect_to(denied_path)
      end
    end
  end
end
