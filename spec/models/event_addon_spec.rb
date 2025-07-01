# frozen_string_literal: true

# == Schema Information
#
# Table name: event_addons
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  addon_id   :integer          not null
#  price      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_event_addons_on_addon_id  (addon_id)
#  index_event_addons_on_event_id  (event_id)
#

require 'rails_helper'

RSpec.describe EventAddon do
  describe 'validations' do
    subject { event_addon }

    let(:event_addon) { build(:event_addon) }

    describe '#price' do
      it { is_expected.to be_valid }

      describe '#set_default_values' do
        let(:event_addon) { build(:event_addon, price: nil) }

        it 'has price set to default price' do
          expect(event_addon.set_default_values).to eq(event_addon.addon.default_price)
        end
      end

      context 'when price is set' do
        let(:price) { 314 }
        let(:event_addon) { build(:event_addon, price:) }

        it 'has price set' do
          expect(event_addon.price).to eq(price)
        end
      end
    end
  end
end
