# frozen_string_literal: true

require 'rails_helper'

describe EventsController, type: :controller do
  let(:event) { create(:event) }
  let(:viewer) { nil }

  before { sign_in viewer if viewer }

  describe 'GET #show' do
    before { get :show, params: { id: event.to_param } }

    context 'when the user is not signed in' do
      it { redirects_to new_event_ticket_request_path(event) }
    end

    context 'when the user is signed in' do
      context 'and is not an event admin' do
        let(:viewer) { create(:user) }

        it { redirects_to new_event_ticket_request_path(event) }
      end

      context 'and is an event admin' do
        let(:viewer) { create(:event_admin, event:).user }

        it { succeeds }
      end
    end
  end

  describe 'GET #new' do
    before { get :new }

    context 'when the user is not signed in' do
      it { redirects_to new_user_session_path }
    end

    context 'when the user is signed in' do
      context 'and is not a site admin' do
        let(:viewer) { create(:user) }

        it { succeeds }
      end

      context 'and is a site admin' do
        let(:viewer) { create(:site_admin).user }

        it { succeeds }
      end
    end
  end

  describe 'POST #create' do
    let(:new_event) { build(:event) }
    let(:new_event_params) do
      time_hash = {}
      hash      = new_event.attributes

      hash.keys.grep(/_time/).each do |time_key|
        time_hash[time_key.to_sym] = TimeHelper.to_flatpickr(hash[time_key].to_time) if hash[time_key].present?
      end

      hash.merge(time_hash)
    end

    let(:make_request) { -> { post :create, params: { event: new_event_params } } }

    # rubocop: disable RSpec/AnyInstance
    before do
      allow_any_instance_of(described_class).to receive(:params).and_return(ActionController::Parameters.new(event: new_event_params))
    end
    # rubocop: enable RSpec/AnyInstance

    it 'does not have a nil start_time' do
      expect(new_event.start_time).not_to be_nil
    end

    it 'has a start time that is a proper datetime' do
      expect(new_event.start_time.to_datetime).to be_a(DateTime)
    end

    it 'has require_role set to true' do
      expect(new_event.require_role).to be_truthy
    end

    context 'when the user is not signed in' do
      before { make_request[] }

      it { redirects_to new_user_session_path }
    end

    context 'when the user is signed in' do
      context 'and is not a site admin' do
        let(:viewer) { create(:user) }

        before { make_request[] }

        it { redirects_to root_path }
      end

      context 'and is a site admin' do
        let(:viewer) { create(:site_admin).user }

        it 'creates an event' do
          expect { make_request[] }.to change(Event, :count).by(1)
        end

        describe 'flash messages' do
          before { make_request[] }

          its(:flash) { is_expected.to be_empty }

          it { redirects_to event_path(Event.last) }
        end

        describe 'new_event_params' do
          subject { new_event_params }

          it { is_expected.to include(:start_time, :end_time) }

          it 'has start times are not nil' do
            expect(new_event_params[:start_time]).not_to be_nil
          end

          it 'has end times are not nil' do
            expect(new_event_params[:end_time]).not_to be_nil
          end

          it 'has start_time' do
            expect(new_event_params[:start_time]).to eql(TimeHelper.to_flatpickr(new_event.start_time.to_time))
          end

          it 'has end_time' do
            expect(new_event_params[:end_time]).to eql(TimeHelper.to_flatpickr(new_event.end_time.to_time))
          end

          it 'is properly formatted' do
            expect(new_event_params[:start_time]).to match(%r{\d{2}/\d{2}/\d{4}, \d{2}:\d{2} (AM|PM)})
          end
        end

        describe 'newly created event' do
          before { make_request[] }

          describe 'event' do
            subject { Event.where(name: new_event.name).first }

            it { is_expected.not_to be_nil }
            it { is_expected.to be_valid }
            it { is_expected.to be_persisted }
          end
        end

        describe 'event creation' do
          subject(:response) { make_request[] }

          let(:created_event) { subject.instance_variable_get(:@event) }

          it { expect { response }.to change(Event, :count) }
          it { is_expected.to have_http_status(:redirect) }
          it { is_expected.to redirect_to(event_path(Event.last)) }
        end
      end
    end
  end

  describe 'GET #index' do
    subject { get :index }

    context 'when viewer is not signed in' do
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when viewer is a site admin' do
      let(:viewer) { create(:site_admin).user }

      before { event }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when viewer is a regular user (not admin)' do
      let(:viewer) { create(:user) }

      it { is_expected.to redirect_to(root_path) }
    end
  end

  describe 'GET #edit' do
    subject { get :edit, params: { id: event.to_param } }

    context 'when viewer is not signed in' do
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      it { succeeds }
    end

    context 'when viewer is a site admin' do
      let(:viewer) { create(:site_admin).user }

      it { succeeds }
    end

    context 'when viewer is a regular user' do
      let(:viewer) { create(:user) }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe 'PATCH #update' do
    subject { patch :update, params: { id: event.to_param, event: update_params } }

    let(:update_params) { { name: 'Updated Event Name' } }

    context 'when viewer is not signed in' do
      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      it { is_expected.to have_http_status(:redirect) }

      it 'updates the event name' do
        subject
        expect(event.reload.name).to eq 'Updated Event Name'
      end
    end

    context 'when viewer is a site admin' do
      let(:viewer) { create(:site_admin).user }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when update fails with invalid params' do
      let(:viewer) { create(:event_admin, event:).user }
      let(:update_params) { { name: '' } }

      it { is_expected.to have_http_status(:ok) }
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: event.to_param } }

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      it 'destroys the event' do
        event # ensure it exists
        expect { subject }.to change(Event, :count).by(-1)
      end

      it { is_expected.to redirect_to(events_url) }
    end
  end

  describe 'GET #guest_list' do
    subject { get :guest_list, params: { id: event.to_param } }

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      before do
        create(:ticket_request, :completed, event:)
        create(:ticket_request, :approved, event:)
      end

      it { succeeds }
    end

    context 'when viewer is not an admin' do
      let(:viewer) { create(:user) }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe 'GET #active_ticket_requests' do
    subject { get :active_ticket_requests, params: { id: event.to_param } }

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      before do
        create(:ticket_request, :completed, event:)
        create(:ticket_request, :pending, event:)
      end

      it { succeeds }
    end
  end

  describe 'POST #add_admin' do
    subject { post :add_admin, params: { id: event.to_param, user_email: new_admin.email } }

    let(:new_admin) { create(:user) }

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      it 'adds the user as an admin' do
        expect { subject }.to change { event.admins.count }.by(1)
      end

      it { is_expected.to redirect_to(event) }
    end

    context 'when user email does not exist' do
      subject { post :add_admin, params: { id: event.to_param, user_email: 'nonexistent@test.com' } }

      let(:viewer) { create(:event_admin, event:).user }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when viewer is not an admin' do
      let(:viewer) { create(:user) }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe 'POST #remove_admin' do
    subject { post :remove_admin, params: { id: event.to_param, user_id: admin_to_remove.user_id } }

    let(:admin_to_remove) { create(:event_admin, event:) }

    context 'when viewer is an event admin' do
      let(:viewer) { create(:event_admin, event:).user }

      it 'removes the admin' do
        admin_to_remove # ensure created
        expect { subject }.to change { event.event_admins.count }.by(-1)
      end

      it { is_expected.to redirect_to(event) }
    end

    context 'when user_id does not match any event admin' do
      # redirect_to :back raises a NoMethodError for back_url in Rails 8
      # because :back redirect is deprecated and there is no HTTP_REFERER
      subject { post :remove_admin, params: { id: event.to_param, user_id: 999_999 } }

      let(:viewer) { create(:event_admin, event:).user }

      it 'raises an error due to missing referer' do
        expect { subject }.to raise_error(NoMethodError, /back_url/)
      end
    end
  end
end
