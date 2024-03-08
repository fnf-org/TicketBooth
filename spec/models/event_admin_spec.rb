# frozen_string_literal: true

# == Schema Information
#
# Table name: event_admins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_event_admins_on_event_id              (event_id)
#  index_event_admins_on_event_id_and_user_id  (event_id,user_id) UNIQUE
#  index_event_admins_on_user_id               (user_id)
#  index_event_admins_on_user_id_only          (user_id)
#
describe EventAdmin do
  describe 'validations' do
    describe '#user' do
      describe 'valid admin' do
        subject(:event_admin) { EventAdmin.make! }

        it { is_expected.to be_valid }
      end

      describe 'nil user id' do
        subject(:event_admin_without_user) { EventAdmin.make!.tap { |ea| ea.user = nil }.validate! }

        it 'invalidates nil user_id' do
          expect { event_admin_without_user }.to raise_error(ArgumentError)
        end
      end

      describe 'nil event id' do
        subject(:event_admin_without_event) { EventAdmin.make!.tap { |ea| ea.event = nil }.validate! }

        it 'invalidates nil event_id' do
          expect { event_admin_without_event }.to raise_error(ArgumentError)
        end
      end

      context 'when the user is already an admin for the event' do
        subject { described_class.make event: }

        let(:event) { Event.make! }
        let(:event_admin) { described_class.make! event: }
        let(:user) { event_admin.user }

        it { is_expected.not_to accept_values_for(:user_id, user.id) }
      end
    end
  end
end
