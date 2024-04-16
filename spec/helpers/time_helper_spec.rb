# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeHelper do
  describe 'to_string_for_flatpickr' do
    it 'convert datetime to a string' do
      expect(described_class.to_string_for_flatpickr(DateTime.new(2024, 4, 20, 8, 37, 48, '-06:00'))).to be_a(String)
    end

    it 'handles nil' do
      expect(described_class.to_string_for_flatpickr(nil)).to be_nil
    end
  end

  describe 'to_datetime_from_picker' do
    it 'converts string to Time' do
      str = '04/17/2024, 4:20 PM'
      out = described_class.to_datetime_from_picker(str)
      expect(out).to be_a(Time)
    end

    it 'raises date error on empty' do
      expect { described_class.to_datetime_from_picker('') }.to raise_error(Date::Error)
    end

    it 'raises date error on bad format' do
      str = '04/17/2024'
      expect { described_class.to_datetime_from_picker(str) }.to raise_error(Date::Error)
    end

    it 'returns nil on nil' do
      expect(described_class.to_datetime_from_picker(nil)).to be_nil
    end
  end

  describe 'convert_times_for_db' do
    it 'returns nil with nil' do
      expect(described_class.convert_times_for_db(nil)).to be_nil
    end

    it 'returns empty with empty in hash' do
      expect(described_class.convert_times_for_db({})).to be_empty
    end

    it 'converts valid time string to datetime' do
      str = '04/17/2024, 4:20 PM'
      test_hash = { start_time: str }
      expect(described_class.convert_times_for_db(test_hash)[:start_time]).to be_a(Time)
    end

    it 'does not convert empty string for time key' do
      test_hash = { start_time: '' }
      expect(described_class.convert_times_for_db(test_hash)).to eq(test_hash)
    end
  end
end
