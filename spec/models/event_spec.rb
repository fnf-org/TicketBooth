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

    describe '#adult_ticket_price' do
      let(:event) { Event.make adult_ticket_price: adult_ticket_price }

      context 'when not present' do
        let(:adult_ticket_price) { nil }
        it { should_not be_valid }
      end

      context 'when set to a number' do
        let(:adult_ticket_price) { 50 }
        it { should be_valid }
      end

      context 'when set to a negative number' do
        let(:adult_ticket_price) { -1 }
        it { should_not be_valid }
      end
    end

    describe '#kid_ticket_price' do
      let(:event) { Event.make kid_ticket_price: kid_ticket_price }

      context 'when not present' do
        let(:kid_ticket_price) { nil }
        it { should be_valid }
      end

      context 'when set to a number' do
        let(:kid_ticket_price) { 50 }
        it { should be_valid }
      end

      context 'when set to a negative number' do
        let(:kid_ticket_price) { -1 }
        it { should_not be_valid }
      end
    end

    describe '#cabin_price' do
      let(:event) { Event.make cabin_price: cabin_price }

      context 'when not present' do
        let(:cabin_price) { nil }
        it { should be_valid }
      end

      context 'when set to a number' do
        let(:cabin_price) { 50 }
        it { should be_valid }
      end

      context 'when set to a negative number' do
        let(:cabin_price) { -1 }
        it { should_not be_valid }
      end
    end

    describe '#max_adult_tickets_per_request' do
      let(:event) do
        Event.make max_adult_tickets_per_request: max_adult_tickets_per_request
      end

      context 'when not present' do
        let(:max_adult_tickets_per_request) { nil }
        it { should be_valid }
      end

      context 'when set to a number' do
        let(:max_adult_tickets_per_request) { 5 }
        it { should be_valid }
      end

      context 'when set to a negative number' do
        let(:max_adult_tickets_per_request) { -1 }
        it { should_not be_valid }
      end
    end

    describe '#max_kid_tickets_per_request' do
      let(:kid_ticket_price) { 10 }
      let(:event) do
        Event.make kid_ticket_price: kid_ticket_price,
                   max_kid_tickets_per_request: max_kid_tickets_per_request
      end

      context 'when not present' do
        let(:max_kid_tickets_per_request) { nil }
        it { should be_valid }
      end

      context 'when set to a number' do
        let(:max_kid_tickets_per_request) { 5 }

        it { should be_valid }

        context 'and a kid ticket price is not set' do
          let(:kid_ticket_price) { nil }
          it { should_not be_valid }
        end
      end

      context 'when set to a negative number' do
        let(:max_kid_tickets_per_request) { -1 }
        it { should_not be_valid }
      end
    end

    describe '#max_cabins_per_request' do
      let(:cabin_price) { 150 }
      let(:event) do
        Event.make cabin_price: cabin_price,
                   max_cabins_per_request: max_cabins_per_request
      end

      context 'when not present' do
        let(:max_cabins_per_request) { nil }
        it { should be_valid }
      end

      context 'when set to a number' do
        let(:max_cabins_per_request) { 5 }
        it { should be_valid }

        context 'and cabin price is not set' do
          let(:cabin_price) { nil }
          it { should_not be_valid }
        end
      end

      context 'when set to a negative number' do
        let(:max_cabins_per_request) { -1 }
        it { should_not be_valid }
      end
    end
  end
end
