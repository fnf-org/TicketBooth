# frozen_string_literal: true

require 'rails_helper'

describe EmailsController, type: :controller do
  describe 'GET #index' do
    subject { get :index, params: { email: } }

    let(:email) { nil }
    let(:user) { create(:user, email: user_email) }
    let(:user_email) { Faker::Internet.email }

    before { user }

    context 'when a proper email is provided' do
      let(:email) { user_email }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when non-existent email is provided' do
      let(:email) { Faker::Internet.email(name: 'smith') }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
