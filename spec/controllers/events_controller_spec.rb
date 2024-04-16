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
        time_hash[time_key.to_sym] = TimeHelper.to_string_for_flatpickr(hash[time_key].to_time) if hash[time_key].present?
      end

      hash.merge(time_hash)
    end

    let(:make_request) { -> { post :create, params: { event: new_event_params } } }

    # rubocop: disable RSpec/AnyInstance
    before do
      allow_any_instance_of(described_class).to receive(:params).and_return(ActionController::Parameters.new(event: new_event_params))
    end

    it 'does not have a nil start_time' do
      expect(new_event.start_time).not_to be_nil
    end

    it 'has a start time that is a proper datetime' do
      expect(new_event.start_time.to_datetime).to be_a(DateTime)
    end

    # rubocop: enable RSpec/AnyInstance

    describe '#permitted_params' do
      subject(:permitted_keys) { permitted_event_keys }

      let(:permitted_event_params) { described_class.new.send(:permitted_params)[:event].to_h.symbolize_keys }
      let(:expected_keys) do
        %i[
          adult_ticket_price
          allow_donations
          allow_financial_assistance
          cabin_price
          early_arrival_price
          end_time
          kid_ticket_price
          late_departure_price
          max_adult_tickets_per_request
          max_cabin_requests
          max_cabins_per_request
          max_kid_tickets_per_request
          name
          require_mailing_address
          start_time
          ticket_requests_end_time
          ticket_sales_end_time
          ticket_sales_start_time
          tickets_require_approval
        ]
      end
      let(:permitted_event_keys) { permitted_event_params.keys.sort }

      it { expect(permitted_keys).to eql(expected_keys) }
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
            expect(new_event_params[:start_time]).to eql(TimeHelper.to_string_for_flatpickr(new_event.start_time.to_time))
          end

          it 'has end_time' do
            expect(new_event_params[:end_time]).to eql(TimeHelper.to_string_for_flatpickr(new_event.end_time.to_time))
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
end
