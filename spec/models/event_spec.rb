require 'spec_helper'

describe Event do
  it 'has a valid factory' do
    Event.make.should be_valid
  end

  describe 'validations' do
    subject { event }

    describe '#name' do
      let(:event) { Event.make name: name }

      context 'when not present' do
        let(:name) { nil }
        it { should_not be_valid }
      end

      context 'when empty' do
        let(:name) { '' }
        it { should_not be_valid }
      end

      context 'when longer than 100 characters' do
        let(:name) { Sham.string(101) }
        it { should_not be_valid }
      end

      context 'with a typical event name' do
        let(:name) { 'Cloudwatch 2013' }
        it { should be_valid }
      end
    end

    describe '#start_time' do
      let(:event) { Event.make start_time: start_time }

      context 'when not present' do
        let(:start_time) { nil }
        it { should_not be_valid }
      end

      context 'when empty' do
        let(:start_time) { '' }
        it { should_not be_valid }
      end
    end

    describe '#end_time' do
      let(:event) { Event.make end_time: end_time }

      context 'when not present' do
        let(:end_time) { nil }
        it { should_not be_valid }
      end

      context 'when empty' do
        let(:end_time) { '' }
        it { should_not be_valid }
      end
    end

    context 'when start time is before end time' do
      let(:event) { Event.make start_time: Time.now, end_time: 1.day.from_now }
      it { should be_valid }
    end

    context 'when start time is after end time' do
      let(:event) { Event.make start_time: 1.day.from_now, end_time: Time.now }
      it { should_not be_valid }
    end
  end
end
