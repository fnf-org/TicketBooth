# frozen_string_literal: true

# == Schema Information
#
# Table name: addons
#
#  id            :bigint           not null, primary key
#  category      :string           not null
#  default_price :integer          not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe Addon do
  describe 'validations' do
    subject { addon }

    describe '#category' do
      context 'when category is known' do
        let(:addon) { build(:addon, category: Addon::CATEGORY_PASS) }

        it { is_expected.to be_valid }
      end

      context 'when category unknown' do
        let(:addon) { build(:addon, category: 'foo') }

        it { is_expected.not_to be_valid }
      end
    end

    describe '#name' do
      context 'when name not present' do
        let(:addon) { build(:addon, name: nil) }

        it { is_expected.not_to be_valid }
      end
    end

    describe '#default_price' do
      context 'when default price not present' do
        let(:addon) { build(:addon, default_price: nil) }

        it { is_expected.not_to be_valid }
      end

      context 'when default price negative' do
        let(:addon) { build(:addon, default_price: -1) }

        it { is_expected.not_to be_valid }
      end

    end
  end

  describe '.find_all_by_category' do
    let(:category) { Addon::CATEGORY_PASS }
    let!(:addon) { create(:addon, category: category) }

    subject(:addons) { described_class.find_all_by_category(category) }

    context 'when category is known' do
      it { is_expected.to be_a(Array) }

      it 'has size of 1' do
        expect(addons.size).to eq(1)
      end

      it 'has known category' do
        expect(addons.first&.category).to eq(category)
      end
    end

    context 'when category is unknown' do
      subject(:addons) { described_class.find_all_by_category('foo') }

      it 'is an empty array' do
        expect(addons).to be_empty
      end
    end
  end
end
