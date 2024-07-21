# frozen_string_literal: true

# == Schema Information
#
# Table name: event_addons
#
#  id         :bigint           not null, primary key
#  price      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  addon_id   :bigint           not null
#  event_id   :bigint           not null
#
# Indexes
#
#  index_event_addons_on_addon_id  (addon_id)
#  index_event_addons_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_id => addons.id)
#  fk_rails_...  (event_id => events.id)
#

require 'rails_helper'

RSpec.describe EventAddon do
  describe 'validations' do
    subject { event_addon }

    let(:event_addon) { build(:event_addon) }

    describe '#price' do
      it { is_expected.to be_valid }

      describe '#set_default_values' do
        it 'has price set to default price' do
          expect(event_addon.set_default_values).to eq(event_addon.addon.default_price)
        end
      end

      context 'sets price' do
        let(:event_addon) { build(:event_addon, price: 314_159) }

        it 'has price set not default price' do
          expect(event_addon.price).to eq(314_159)
        end
      end
    end
  end
end