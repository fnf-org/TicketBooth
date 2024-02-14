# frozen_string_literal: true

require 'spec_helper'

describe Event do
  it 'has a valid factory' do
    Event.make.should be_valid
  end

  describe 'normalization' do
    it { should normalize(:name) }
    it { should normalize(:name).from('  Trim Spaces  ').to('Trim Spaces') }
    it { should normalize(:name).from('Squish  Spaces').to('Squish Spaces') }
  end

  describe 'validations' do
    describe '#name' do
      it { should accept_values_for(:name, 'CloudWatch 2013') }
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

    describe '#ticket_sales_start_time' do
      it { should accept_values_for(:ticket_sales_start_time, Time.now, nil, '') }
    end

    describe '#ticket_sales_end_time' do
      it { should accept_values_for(:ticket_sales_start_time, Time.now, nil, '') }
    end

    context 'when ticket sales start time is before end time' do
      subject do
        Event.make ticket_sales_start_time: Time.now, ticket_sales_end_time: 1.day.from_now
      end

      it { should be_valid }
    end

    context 'when ticket sales start time is after end time' do
      subject do
        Event.make ticket_sales_start_time: 1.day.from_now, ticket_sales_end_time: Time.now
      end

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

    describe '#max_cabin_requests' do
      context 'when cabin_price is set' do
        subject { Event.make cabin_price: 10 }
        it { should accept_values_for(:max_cabin_requests, nil, '', 10) }
        it { should_not accept_values_for(:max_cabin_requests, 0, -1) }
      end

      context 'when cabin_price is not set' do
        subject { Event.make cabin_price: nil }
        it { should accept_values_for(:max_cabin_requests, nil, '') }
        it { should_not accept_values_for(:max_cabin_requests, 10) }
      end
    end
  end

  describe '#admin?' do
    let(:event) { Event.make! }
    subject { event.admin?(user) }

    context 'when given a normal user' do
      let(:user) { User.make! }
      it { should be false }
    end

    context 'when given a site admin' do
      let(:user) { User.make! :site_admin }
      it { should be true }
    end

    context 'when given an event admin' do
      let(:user) { EventAdmin.make!(event:).user }
      it { should be true }
    end

    context 'when given an admin of another event' do
      let(:user) { EventAdmin.make!.user }
      it { should be false }
    end
  end

  describe '#cabins_available?' do
    let(:cabin_price) { nil }
    let(:max_cabin_requests) { nil }
    let(:event) do
      Event.make! cabin_price:, max_cabin_requests:
    end
    subject { event.cabins_available? }

    context 'when no cabin price is set' do
      let(:cabin_price) { nil }
      it { should be false }
    end

    context 'when cabin price is set' do
      let(:cabin_price) { 100 }

      context 'when no maximum specified for the number of cabin requests' do
        let(:max_cabin_requests) { nil }
        it { should be true }
      end

      context 'when a maximum is specified for the number of cabin requests' do
        let(:max_cabin_requests) { 10 }

        context 'when there are fewer cabins requested than the maximum' do
          it { should be true }
        end

        context 'when the number of cabins requested has met or exceeded the maximum' do
          before do
            TicketRequest.make! event:, cabins: max_cabin_requests
          end

          it { should be false }
        end
      end
    end
  end

  describe '#ticket_sales_open?' do
    let(:start_time) { 1.day.from_now }
    let(:end_time) { 2.days.from_now }
    let(:ticket_sale_start_time) { nil }
    let(:ticket_sale_end_time) { nil }

    let(:event) do
      Event.make! start_time:,
                  end_time:,
                  ticket_sales_start_time: ticket_sale_start_time,
                  ticket_sales_end_time: ticket_sale_end_time
    end

    subject { event.ticket_sales_open? }

    context 'when the event has ended' do
      let(:start_time) { 2.days.ago }
      let(:end_time) { 1.days.ago }
      it { should be false }
    end

    context 'when the ticket sale start time is specified' do
      context 'and the ticket sale start time has passed' do
        let(:ticket_sale_start_time) { 1.day.ago }

        context 'and the ticket sale end time is not specified' do
          it { should be true }
        end

        context 'and the ticket sale end time has not passed' do
          let(:ticket_sale_end_time) { 1.day.from_now }
          it { should be true }
        end

        context 'and the ticket sale end time has passed' do
          let(:ticket_sale_end_time) { 1.hour.ago }
          it { should be false }
        end
      end

      context 'and the start time has not passed' do
        let(:ticket_sale_start_time) { 1.day.from_now }
        it { should be false }
      end
    end

    context 'when the ticket sale start time is not specified' do
      context 'and the ticket sale end time is not specified' do
        it { should be true }
      end

      context 'and the ticket sale end time is specified' do
        context 'and the ticket sale end time has passed' do
          let(:ticket_sale_end_time) { 1.day.ago }
          it { should be false }
        end

        context 'and the ticket sale end time has not passed' do
          let(:ticket_sale_end_time) { 1.hour.from_now }
          it { should be true }
        end
      end
    end
  end
end
