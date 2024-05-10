# frozen_string_literal: true

require 'rails_helper'

# rubocop: disable RSpec
describe PaymentsController, type: :controller do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  let(:ticket_request) { create(:ticket_request, user:) }
  let(:payment) { create(:payment, ticket_request:) }
  before { sign_in user if user }

  describe 'GET #show' do
    subject { get(:show, params: { id: payment.id }) }

    context 'when payment exists' do
      it { succeeds }
    end

    context 'when viewer is not the owner of the ticket request' do
      let(:ticket_request) { create(:ticket_request) }
      let(:payment) { create(:payment, ticket_request:) }

      it { is_expected.to have_http_status(:redirect) }
    end
  end
end
# rubocop:enable
