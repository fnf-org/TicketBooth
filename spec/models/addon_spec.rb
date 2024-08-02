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
end
