require 'spec_helper'

describe TicketRequestsController do
  let(:viewer) { nil }
  before { sign_in viewer if viewer }

  describe 'GET #index' do
    let(:event) { Event.make! }
    let(:ticket_requests) { TicketRequest.make_list! 3 }
    before { get :index, event_id: event.to_param }

    context 'when viewer not signed in' do
      it { redirects }
    end

    context 'when viewer is a normal user' do
      let(:viewer) { User.make! }
      it { redirects }
    end

    context 'when viewer is the event admin' do
      let(:viewer) { EventAdmin.make!(event: event).user }
      it { succeeds }
    end

    context 'when viewer is a site admin' do
      let(:viewer) { User.make! :site_admin }
      it { succeeds }
    end
  end

  describe 'GET #show' do
    let(:user) { User.make! }
    let(:ticket_request) { TicketRequest.make! user: user }

    before do
      get :show, event_id: ticket_request.event.to_param,
                 id: ticket_request.to_param
    end

    context 'when viewer not signed in' do
      it { redirects }
    end

    context 'when viewer is not the owner of the ticket request' do
      let(:viewer) { User.make! }
      it { redirects_to root_path }
    end

    context 'when viewer is the owner of the ticket request' do
      let(:viewer) { user }
      it { succeeds }
    end

    context 'when viewer is an event admin' do
      let(:viewer) { EventAdmin.make!(event: ticket_request.event).user }
      it { succeeds }
    end

    context 'when viewer is a site admin' do
      let(:viewer) { User.make! :site_admin }
      it { succeeds }
    end
  end

  describe 'GET #new' do
    let(:event) { Event.make! }
    before { get :new, event_id: event.to_param }

    context 'when viewer not signed in' do
      it { succeeds }
    end

    context 'when viewer signed in' do
      let(:viewer) { User.make! }
      it { succeeds }
    end
  end

  describe 'GET #edit' do
    let(:user) { User.make! }
    let(:ticket_request) { TicketRequest.make! user: user }

    before do
      get :edit, event_id: ticket_request.event.to_param,
                 id: ticket_request.to_param
    end

    context 'when viewer not signed in' do
      it { redirects }
    end

    context 'when viewer is not owner of the ticket request' do
      let(:viewer) { User.make! }
      it { redirects_to root_path }
    end

    context 'when viewer is owner of the ticket request' do
      let(:viewer) { user }
      it { redirects_to root_path }
    end

    context 'when viewer is the event admin' do
      let(:viewer) { EventAdmin.make!(event: ticket_request.event).user }
      it { succeeds }
    end

    context 'when viewer is a site admin' do
      let(:viewer) { User.make! :site_admin }
      it { succeeds }
    end
  end
end
