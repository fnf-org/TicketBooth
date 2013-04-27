require 'spec_helper'

describe Event do
  it 'has a valid factory' do
    Event.make.should be_valid
  end

  describe 'normalization' do
    it { should normalize(:name) }
    it { should normalize(:name).from('  Trim Spaces  ').to('Trim Spaces')}
    it { should normalize(:name).from('Squish  Spaces').to('Squish Spaces')}
  end

  describe 'validations' do
    describe '#name' do
      it { should accept_values_for(:name, 'Cloudwatch 2013') }
      it { should_not accept_values_for(:name, nil, '', Sham.string(101)) }
    end

    describe '#start_time' do
      it { should accept_values_for(:start_time, Time.now) }
      it { should_not accept_values_for(:start_time, nil, '') }
    end

    describe '#end_time' do
      it { should accept_values_for(:start_time, Time.now) }
      it { should_not accept_values_for(:end_time, nil, '') }
    end

    context 'when start time is before end time' do
      subject { Event.make start_time: Time.now, end_time: 1.day.from_now }
      it { should be_valid }
    end

    context 'when start time is after end time' do
      subject { Event.make start_time: 1.day.from_now, end_time: Time.now }
      it { should_not be_valid }
    end

    describe '#adult_ticket_price' do
      it { should accept_values_for(:adult_ticket_price, 0, 50) }
      it { should_not accept_values_for(:adult_ticket_price, nil, '', -1) }
    end

    describe '#kid_ticket_price' do
      it { should accept_values_for(:kid_ticket_price, nil, '', 0, 50) }
      it { should_not accept_values_for(:kid_ticket_price, -1) }
    end

    describe '#cabin_price' do
      it { should accept_values_for(:cabin_price, nil, '', 0, 50) }
      it { should_not accept_values_for(:cabin_price, -1) }
    end

    describe '#max_adult_tickets_per_request' do
      it { should accept_values_for(:max_adult_tickets_per_request, nil, '', 50) }
      it { should_not accept_values_for(:max_adult_tickets_per_request, 0, -1) }
    end

    describe '#max_kid_tickets_per_request' do
      context 'when kid_ticket_price is set' do
        subject { Event.make kid_ticket_price: 10 }
        it { should accept_values_for(:max_kid_tickets_per_request, nil, '', 10) }
        it { should_not accept_values_for(:max_kid_tickets_per_request, 0, -1) }
      end

      context 'when kid_ticket_price is not set' do
        subject { Event.make kid_ticket_price: nil }
        it { should_not accept_values_for(:max_kid_tickets_per_request, 10) }
      end
    end

    describe '#max_cabins_per_request' do
      context 'when cabin_price is set' do
        subject { Event.make cabin_price: 10 }
        it { should accept_values_for(:max_cabins_per_request, nil, '', 10) }
        it { should_not accept_values_for(:max_cabins_per_request, 0, -1) }
      end

      context 'when cabin_price is not set' do
        subject { Event.make cabin_price: nil }
        it { should_not accept_values_for(:max_cabins_per_request, 10) }
      end
    end
  end
end
