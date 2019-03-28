require 'spec_helper'

describe TicketRequestsController, type: :controller do
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
      it { redirects_to new_event_ticket_request_path(ticket_request.event) }
    end

    context 'when viewer is owner of the ticket request' do
      let(:viewer) { user }
      it { succeeds }
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

  describe 'POST #create' do
    let(:event) { Event.make! }
    let(:valid_params) { TicketRequest.valid_attributes event_id: event.to_param }

    def make_request
      post :create, event_id: event.to_param, ticket_request: valid_params
    end

    context 'when event ticket sales are closed' do
      before do
        Time.warp(event.end_time + 1.hour) { make_request }
      end

      it 'renders an error message' do
        flash[:error].should_not be_nil
      end
    end

    context 'when viewer already signed in' do
      let(:user) { User.make! }
      let(:viewer) { user }

      it 'creates a ticket request' do
        expect { make_request }.to change { TicketRequest.count }.by(1)
      end

      it 'assigned the ticket request to the viewer' do
        expect { make_request }.to change { viewer.ticket_requests.count }.by(1)
      end
    end

    context 'when viewer is not signed in' do
      let(:email) { Sham.email_address.downcase }
      let(:password) { Sham.string(8) }

      let(:user_attributes) do
        {
          name: Sham.words(2),
          email: email,
          password: password,
        }
      end

      let(:valid_params) do
        TicketRequest.valid_attributes event_id: event.to_param,
                                       user_attributes: user_attributes
      end

      it 'creates a user with the specified email address' do
        make_request
        User.find_by_email(email).should_not be_nil
      end

      it 'creates a ticket request' do
        expect { make_request }.to change { TicketRequest.count }.by(1)
      end

      it 'assigns the ticket request to the created user' do
        make_request
        User.find_by_email(email).ticket_requests.count.should == 1
      end

      it 'signs in the created user' do
        make_request
        subject.current_user.should == User.find_by_email(email)
      end
    end
  end
end
