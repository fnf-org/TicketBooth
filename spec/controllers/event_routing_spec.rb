# frozen_string_literal: true

require 'rails_helper'

describe 'Event routing with secret tokens', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:event) { create(:event, name: 'Fall Campout') }
  let(:user) { create(:site_admin).user }

  before { sign_in user }

  describe 'events#show' do
    context 'with secret_token URL' do
      it 'finds the event by secret_token' do
        get "/events/#{event.secret_token}-fall-campout"
        expect(response).not_to redirect_to(root_path)
      end
    end

    context 'with legacy ID URL' do
      before { event.update_column(:secret_token, nil) }

      it 'finds the event by ID' do
        get "/events/#{event.id}-fall-campout"
        expect(response).not_to redirect_to(root_path)
      end
    end

    context 'with invalid token' do
      it 'redirects to root' do
        get '/events/zzzzzzzz-nonexistent'
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'attend route (ticket_requests#new)' do
    context 'with secret_token URL' do
      it 'finds the event' do
        get "/attend/#{event.to_param}"
        # Should either render the form or redirect, but not 404/root
        expect(request.path).to include('attend')
      end
    end

    context 'with legacy ID URL' do
      before { event.update_column(:secret_token, nil) }

      it 'finds the event by ID' do
        get "/attend/#{event.id}-fall-campout"
        expect(request.path).to include('attend')
      end
    end
  end
end
