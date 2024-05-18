# frozen_string_literal: true

require 'rails_helper'

describe HomeController, type: :controller do
  describe 'GET #index' do
    subject { get(:index) }

    before { sign_in viewer if viewer }

    context 'when site admin' do
      let(:viewer) { create(:site_admin).user }

      it { expect(response).to have_http_status(:ok) }
    end

    context 'when not logged in' do
      let(:viewer) { nil }

      it { expect(response).to have_http_status(:ok) }
    end
  end
end
