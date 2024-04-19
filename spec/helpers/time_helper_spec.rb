# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimeHelper do
  let(:in_str) { '04/20/2024, 4:20 PM' }

  describe 'to_string_for_flatpickr' do
    it 'convert datetime to a string' do
      expect(described_class.to_string_for_flatpickr(DateTime.new(2024, 4, 20, 8, 37, 48, -7))).to be_a(String)
    end

    it 'handles nil' do
      expect(described_class.to_string_for_flatpickr(nil)).to be_nil
    end
  end

  describe 'to_datetime_from_picker' do

    it 'converts string to Time' do
      out = described_class.to_datetime_from_picker(in_str)
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
    let(:bad_str) { '04.17.2024' }
    let(:str_epoch) { DateTime.parse('2024-04-20T16:20:00 -0700').to_time.to_i }
    let(:test_hash) { { start_time: in_str } }

    it 'returns invalid arg' do
      expect(described_class.convert_times_for_db(nil)).to be_nil
      expect(described_class.convert_times_for_db({})).to be_empty
    end

    it 'raises type error with bad type arg' do
      expect { described_class.convert_times_for_db(bad_str) }.to raise_error(TypeError)
    end

    it 'raises date error on bad format' do
      expect { described_class.convert_times_for_db({ start_time: bad_str }) }.to raise_error(Date::Error)
    end

    it 'converts time string to Time' do
      out_time = described_class.convert_times_for_db(test_hash)[:start_time]
      expect(out_time).to be_a(Time)
      expect(out_time.to_i).to eq(str_epoch)
    end

    it 'does not convert empty string for time key' do
      test_hash = { start_time: '' }
      expect(described_class.convert_times_for_db(test_hash)).to eq(test_hash)
    end
  end
end
