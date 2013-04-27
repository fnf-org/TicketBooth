require 'spec_helper'

describe EventAdmin do
  it 'has a valid factory' do
    EventAdmin.make.should be_valid
  end

  describe 'validations' do
    describe '#user' do
      it { should accept_values_for(:user_id, User.make!.id) }
      it { should_not accept_values_for(:user_id, nil) }

      context 'when the user does not exist' do
        let(:user) { User.make! }

        before do
          user.destroy
        end

        it { should_not accept_values_for(:user_id, user.id) }
      end

      context 'when the user is already an admin for the event' do
        let(:event) { Event.make! }
        let(:event_admin) { EventAdmin.make! event: event }
        let(:user) { event_admin.user }
        subject { EventAdmin.make event: event }

        it { should_not accept_values_for(:user_id, user.id) }
      end
    end

    describe '#event' do
      it { should accept_values_for(:event_id, Event.make!.id) }
      it { should_not accept_values_for(:event_id, nil) }

      context 'when the event does not exist' do
        let(:event) { Event.make! }

        before do
          event.destroy
        end

        it { should_not accept_values_for(:event_id, event.id) }
      end
    end
  end
end
