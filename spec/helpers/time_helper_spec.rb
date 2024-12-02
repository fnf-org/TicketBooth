# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeHelper do
  let(:valid_input) { '04/20/2024, 4:20 PM -0700' }

  describe '.to_flatpickr' do
    let(:date) { DateTime.new(2024, 4, 20, 8, 37, 48, -7) }

    it 'convert datetime to a string' do
      expect(described_class.to_flatpickr(date)).to be_a(String)
    end

    it 'handles nil' do
      expect(described_class.to_flatpickr(nil)).to be_nil
    end
  end

  describe '.from_flatpickr' do
    let(:out) { described_class.from_flatpickr(valid_input) }

    it 'converts string to Time' do
      expect(out).to be_a(Time)
    end

    it 'raises date error on empty' do
      expect { described_class.from_flatpickr('') }.to raise_error(Date::Error)
    end

    it 'raises date error on bad format' do
      str = '04/17/2024'
      expect { described_class.from_flatpickr(str) }.to raise_error(Date::Error)
    end

    it 'returns nil on nil' do
      expect(described_class.from_flatpickr(nil)).to be_nil
    end
  end

  describe '.normalize_time_attributes' do
    let(:test_hash) { { start_time: valid_input } }
    let(:date_epoch) { '2024-04-20T16:20:00 -0700' }
    let(:date_epoch_string) { DateTime.parse(date_epoch).to_time.to_i }

    describe 'empty arguments' do
      subject { described_class.normalize_time_attributes(input) }

      describe 'nil' do
        let(:input) { nil }

        it { is_expected.to be_nil }
      end

      describe 'empty hash' do
        let(:input) { {} }

        it { is_expected.to be_empty }
      end
    end

    describe 'invalid non-empty arguments' do
      let(:invalid_input) { '04.17.2024' }

      it 'raises type error with bad type arg' do
        expect { described_class.normalize_time_attributes(invalid_input) }.to raise_error(ArgumentError)
      end

      it 'raises date error on bad format' do
        expect { described_class.normalize_time_attributes({ start_time: invalid_input }) }.to raise_error(Date::Error)
      end

      describe 'empty string for time' do
        let(:test_hash) { { start_time: '' } }

        it 'does not convert empty string for time key' do
          expect(described_class.normalize_time_attributes(test_hash)).to eq(test_hash)
        end
      end
    end

    describe 'valid arguments' do
      let(:out_time) { described_class.normalize_time_attributes(test_hash)[:start_time] }

      it 'converts time string to Time' do
        expect(out_time).to be_a(Time)
      end

      it 'converts to a correct time' do
        expect(out_time.to_i).to eq(date_epoch_string)
      end
    end
  end
end
