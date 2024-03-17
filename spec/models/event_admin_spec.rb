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
#  index_event_admins_on_event_id_and_user_id  (event_id,user_id) UNIQUE
#  index_event_admins_on_user_id               (user_id)
require 'rails_helper'

describe EventAdmin do
  subject(:event_admin) { event_admin_maker[nil_method] }

  let(:nil_method) { nil }
  let(:event) { event_admin.event }
  let(:user) { event_admin.user }

  let(:event_admin_maker) do
    lambda do |nil_method = nil|
      described_class.make!.tap { |ea| nil_method ? ea.send("#{nil_method}=", nil) : ea }
    end
  end

  describe 'validations' do
    describe 'valid admin' do
      it { is_expected.to be_valid }
    end

    describe '#user' do
      describe 'nil user' do
        subject(:event_admin_no_user) { event_admin_maker.call(:user_id) }

        it 'invalidates nil user_id' do
          expect { event_admin_no_user.validate! }.to raise_error(ArgumentError)
        end
      end

      describe 'nil event' do
        subject(:event_admin_without_event) { event_admin_maker.call(:event_id) }

        it 'invalidates nil user_id' do
          expect { event_admin_without_event.validate! }.to raise_error(ArgumentError)
        end
      end

      describe 'event admin uniqueness' do
        it 'has already event_admin for this event' do
          expect(described_class.where(event:, user:).count).to eq(1)
        end

        describe 'when the user is already an admin for the event' do
          subject(:another_event_admin) { described_class.make!(event:, user:) }

          it 'raises validation error' do
            expect { another_event_admin }.to raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end
    end
  end
end
