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
      it { is_expected.to accept_values_for(:user_id, User.make!.id) }
      it { is_expected.not_to accept_values_for(:user_id, nil) }

      context 'when the user is already an admin for the event' do
        subject { described_class.make event: }

        let(:event) { Event.make! }
        let(:event_admin) { described_class.make! event: }
        let(:user) { event_admin.user }

        it { is_expected.not_to accept_values_for(:user_id, user.id) }
      end
    end

    describe '#event' do
      it { is_expected.to accept_values_for(:event_id, Event.make!.id) }
      it { is_expected.not_to accept_values_for(:event_id, nil) }
    end
  end
end
