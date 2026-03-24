# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  # Use an anonymous controller that inherits from ApplicationController
  controller do
    skip_before_action :authenticate_user_from_token!
    skip_before_action :redirect_path

    def test_set_event
      set_event
      if @event
        render plain: "Event: #{@event.name}"
      else
        head :not_found unless performed?
      end
    end

    def test_require_event_admin
      set_event
      return unless @event

      require_event_admin
      render plain: 'Admin access granted' unless performed?
    end

    def test_site_host
      render plain: site_host
    end

    def test_site_url
      render plain: site_url
    end

    def test_alert_log_level
      render plain: alert_log_level(params[:alert_type]).to_s
    end

    def test_alert_log_color
      color = alert_log_color(params[:alert_type])
      render plain: (color || 'none').to_s
    end

    def test_convert_int_param_safely
      result = convert_int_param_safely(params[:value])
      render plain: result.to_s
    end

    private

    def permitted_params
      params.permit(:event_id, :alert_type, :value)
            .to_hash
            .with_indifferent_access
    end
  end

  before do
    routes.draw do
      get 'test_set_event' => 'anonymous#test_set_event'
      get 'test_require_event_admin' => 'anonymous#test_require_event_admin'
      get 'test_site_host' => 'anonymous#test_site_host'
      get 'test_site_url' => 'anonymous#test_site_url'
      get 'test_alert_log_level' => 'anonymous#test_alert_log_level'
      get 'test_alert_log_color' => 'anonymous#test_alert_log_color'
      get 'test_convert_int_param_safely' => 'anonymous#test_convert_int_param_safely'
    end
  end

  describe '#set_event' do
    context 'when event_id is a secret token format' do
      subject { get :test_set_event, params: { event_id: event.to_param } }

      it { is_expected.to have_http_status(:ok) }

      it 'finds the event' do
        subject
        expect(response.body).to include(event.name)
      end
    end

    context 'when event_id is an integer-based format' do
      subject { get :test_set_event, params: { event_id: event.to_param } }

      before { event.update_column(:secret_token, nil) }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when event does not exist' do
      subject { get :test_set_event, params: { event_id: 'nonexistent-event' } }

      it { is_expected.to have_http_status(:redirect) }
    end

    context 'when event_id is zero' do
      subject { get :test_set_event, params: { event_id: '0' } }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe '#require_event_admin' do
    before { sign_in viewer }

    context 'when current_user is an event admin' do
      subject { get :test_require_event_admin, params: { event_id: event.to_param } }

      let(:viewer) { create(:event_admin, event:).user }

      it { is_expected.to have_http_status(:ok) }

      it 'renders admin access granted' do
        subject
        expect(response.body).to eq 'Admin access granted'
      end
    end

    context 'when current_user is a site admin' do
      subject { get :test_require_event_admin, params: { event_id: event.to_param } }

      let(:viewer) { create(:site_admin).user }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when current_user is not an admin' do
      subject { get :test_require_event_admin, params: { event_id: event.to_param } }

      let(:viewer) { create(:user) }

      it { is_expected.to have_http_status(:redirect) }
    end
  end

  describe '#alert_log_level' do
    subject { get :test_alert_log_level, params: { alert_type: } }

    context 'for notice' do
      let(:alert_type) { 'notice' }

      it 'returns info' do
        subject
        expect(response.body).to eq 'info'
      end
    end

    context 'for error' do
      let(:alert_type) { 'error' }

      it 'returns error' do
        subject
        expect(response.body).to eq 'error'
      end
    end

    context 'for alert' do
      let(:alert_type) { 'alert' }

      it 'returns error' do
        subject
        expect(response.body).to eq 'error'
      end
    end

    context 'for warning' do
      let(:alert_type) { 'warning' }

      it 'returns warn' do
        subject
        expect(response.body).to eq 'warn'
      end
    end

    context 'for unknown type' do
      let(:alert_type) { 'other' }

      it 'returns debug' do
        subject
        expect(response.body).to eq 'debug'
      end
    end
  end

  describe '#alert_log_color' do
    subject { get :test_alert_log_color, params: { alert_type: } }

    context 'for notice' do
      let(:alert_type) { 'notice' }

      it 'returns blue' do
        subject
        expect(response.body).to eq 'blue'
      end
    end

    context 'for error' do
      let(:alert_type) { 'error' }

      it 'returns red' do
        subject
        expect(response.body).to eq 'red'
      end
    end

    context 'for warning' do
      let(:alert_type) { 'warning' }

      it 'returns yellow' do
        subject
        expect(response.body).to eq 'yellow'
      end
    end

    context 'for unknown type' do
      let(:alert_type) { 'other' }

      it 'returns none' do
        subject
        expect(response.body).to eq 'none'
      end
    end
  end

  describe '#convert_int_param_safely' do
    context 'with a valid integer string' do
      subject { get :test_convert_int_param_safely, params: { value: '42' } }

      it 'converts the string to an integer' do
        subject
        expect(response.body).to eq '42'
      end
    end

    context 'with an invalid string' do
      subject { get :test_convert_int_param_safely, params: { value: 'abc' } }

      it 'returns empty string (nil.to_s)' do
        subject
        expect(response.body).to eq ''
      end
    end
  end

  describe '#authenticate_user_from_token!' do
    # Testing token auth on the main anonymous controller
    # requires re-enabling the before_action

    context 'when valid user_token is provided' do
      let(:token) { user.generate_auth_token! }

      it 'signs in the user' do
        # Directly call the method on a controller instance
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(user_id: user.id.to_s, user_token: token)
        )
        controller.send(:authenticate_user_from_token!)
        expect(controller.current_user).to eq user
      end
    end

    context 'when invalid user_token is provided' do
      before { user.generate_auth_token! }

      it 'does not sign in the user' do
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(user_id: user.id.to_s, user_token: 'wrong_token')
        )
        controller.send(:authenticate_user_from_token!)
        expect(controller.current_user).to be_nil
      end
    end

    context 'when only user_token is provided (no user_id)' do
      let(:token) { user.generate_auth_token! }

      it 'finds and signs in the user via token lookup' do
        allow(controller).to receive(:params).and_return(
          ActionController::Parameters.new(user_token: token)
        )
        controller.send(:authenticate_user_from_token!)
        expect(controller.current_user).to eq user
      end
    end
  end
end
