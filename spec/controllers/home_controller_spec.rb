# frozen_string_literal: true

require 'rails_helper'

describe HomeController, type: :controller do
  describe 'GET #index' do
    context 'when no live events exist' do
      context 'and user is not signed in' do
        before { get :index }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'and user is a site admin' do
        let(:user) { create(:site_admin).user }

        before do
          sign_in user
          get :index
        end

        it { expect(response).to redirect_to(events_path) }
      end
    end

    context 'when a live event exists' do
      let!(:event) do
        create(:event,
               start_time: 1.month.from_now,
               end_time: 1.month.from_now + 3.days,
               ticket_sales_start_time: 1.week.ago,
               ticket_sales_end_time: 1.month.from_now)
      end

      context 'and user is not signed in' do
        before { get :index }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'and user is a site admin' do
        let(:user) { create(:site_admin).user }

        before do
          sign_in user
          get :index
        end

        it { expect(response).to redirect_to(events_path) }
      end

      context 'and user has an existing ticket request' do
        let(:user) { create(:user) }
        let!(:ticket_request) { create(:ticket_request, event:, user:) }

        before do
          sign_in user
          get :index
        end

        it { expect(response).to redirect_to(event_ticket_request_path(event_id: event.id, id: ticket_request.id)) }
      end

      context 'and user has no ticket request' do
        let(:user) { create(:user) }

        before do
          sign_in user
          get :index
        end

        it { expect(response).to have_http_status(:ok) }
      end
    end
  end
end
