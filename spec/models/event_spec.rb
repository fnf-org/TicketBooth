# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                            :bigint           not null, primary key
#  adult_ticket_price            :decimal(8, 2)
#  allow_donations               :boolean          default(FALSE), not null
#  allow_financial_assistance    :boolean          default(FALSE), not null
#  cabin_price                   :decimal(8, 2)
#  early_arrival_price           :decimal(8, 2)    default(0.0)
#  end_time                      :datetime
#  kid_ticket_price              :decimal(8, 2)
#  late_departure_price          :decimal(8, 2)    default(0.0)
#  max_adult_tickets_per_request :integer
#  max_cabin_requests            :integer
#  max_cabins_per_request        :integer
#  max_kid_tickets_per_request   :integer
#  name                          :string
#  photo                         :string
#  require_mailing_address       :boolean          default(FALSE), not null
#  start_time                    :datetime
#  ticket_requests_end_time      :datetime
#  ticket_sales_end_time         :datetime
#  ticket_sales_start_time       :datetime
#  tickets_require_approval      :boolean          default(TRUE), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null

require 'rails_helper'

RSpec.describe Event do
  subject(:event) { build(:event, **params) }

  let(:params) { {} }

  it { is_expected.to be_valid }

  describe '#to_param' do
    context 'given an event that exists in the database' do
      subject(:event) { create(:event, name: 'Summer Campout XII') }

      its(:to_param) { is_expected.to eq "#{event.id}--summer-campout-xii" }
    end
  end

  describe 'normalization' do
    it { is_expected.to normalize(:name) }
    it { is_expected.to normalize(:name).from('  Trim Spaces  ').to('Trim Spaces') }
    it { is_expected.to normalize(:name).from('Squish  Spaces').to('Squish Spaces') }

    describe '#slug' do
      let(:params) { { name: 'Summer Campout XIII' } }

      before { event.validate }

      its(:slug) { is_expected.to eq 'summer-campout-xiii' }
    end
  end

  describe 'event title' do
    let(:params) { { start_time: TimeHelper.from_flatpickr('10/1/2030, 12:00 PM') } }

    describe '#starting' do
      subject { event.starting }

      it { is_expected.to eq 'Tuesday, October 1, 2030 @ 12:00 PM' }
    end

    describe '#long_name' do
      subject { event.long_name }

      it { is_expected.to eq "#{event.name} (Starting #{event.starting})" }
    end
  end

  describe 'validations' do
    describe '#name' do
      it { is_expected.to accept_values_for(:name, 'CloudWatch 2013') }
      it { is_expected.not_to accept_values_for(:name, nil, '', 'x' * 101) }
    end

    describe '#start_time' do
      it { is_expected.to accept_values_for(:start_time, Time.zone.now) }
      it { is_expected.not_to accept_values_for(:start_time, nil, '') }
    end

    describe '#end_time' do
      it { is_expected.to accept_values_for(:start_time, Time.zone.now) }
      it { is_expected.not_to accept_values_for(:end_time, nil, '') }
    end

    context 'when start time is before end time' do
      subject { build(:event, start_time: Time.zone.now, end_time: 1.day.from_now) }

      it { is_expected.to be_valid }
    end

    context 'when start time is after end time' do
      subject { build(:event, start_time: 1.day.from_now, end_time: Time.zone.now) }

      it { is_expected.not_to be_valid }
    end

    describe '#ticket_sales_start_time' do
      it { is_expected.to accept_values_for(:ticket_sales_start_time, Time.zone.now, nil, '') }
    end

    describe '#ticket_sales_end_time' do
      it { is_expected.to accept_values_for(:ticket_sales_start_time, Time.zone.now, nil, '') }
    end

    context 'when ticket sales start time is before end time' do
      subject do
        build(:event, ticket_sales_start_time: Time.zone.now, ticket_sales_end_time: 1.day.from_now)
      end

      it { is_expected.to be_valid }
    end

    context 'when ticket sales start time is after end time' do
      subject do
        build(:event, ticket_sales_start_time: 1.day.from_now, ticket_sales_end_time: Time.zone.now)
      end

      it { is_expected.not_to be_valid }
    end

    describe '#adult_ticket_price' do
      it { is_expected.to accept_values_for(:adult_ticket_price, 0, 50) }
      it { is_expected.not_to accept_values_for(:adult_ticket_price, nil, '', -1) }
    end

    describe '#kid_ticket_price' do
      it { is_expected.to accept_values_for(:kid_ticket_price, nil, '', 0, 50) }
      it { is_expected.not_to accept_values_for(:kid_ticket_price, -1) }
    end

    describe '#cabin_price' do
      it { is_expected.to accept_values_for(:cabin_price, nil, '', 0, 50) }
      it { is_expected.not_to accept_values_for(:cabin_price, -1) }
    end

    describe '#max_adult_tickets_per_request' do
      it { is_expected.to accept_values_for(:max_adult_tickets_per_request, nil, '', 50) }
      it { is_expected.not_to accept_values_for(:max_adult_tickets_per_request, 0, -1) }
    end

    describe '#max_kid_tickets_per_request' do
      context 'when kid_ticket_price is set' do
        subject { build(:event, kid_ticket_price: 10) }

        it { is_expected.to accept_values_for(:max_kid_tickets_per_request, nil, '', 10) }
        it { is_expected.not_to accept_values_for(:max_kid_tickets_per_request, 0, -1) }
      end

      context 'when kid_ticket_price is not set' do
        subject { build(:event, kid_ticket_price: nil) }

        it { is_expected.not_to accept_values_for(:max_kid_tickets_per_request, 10) }
      end
    end

    describe '#max_cabins_per_request' do
      context 'when cabin_price is set' do
        subject { build(:event, cabin_price: 10) }

        it { is_expected.to accept_values_for(:max_cabins_per_request, nil, '', 10) }
        it { is_expected.not_to accept_values_for(:max_cabins_per_request, 0, -1) }
      end

      context 'when cabin_price is not set' do
        subject { build(:event, cabin_price: nil) }

        it { is_expected.not_to accept_values_for(:max_cabins_per_request, 10) }
      end
    end

    describe '#max_cabin_requests' do
      context 'when cabin_price is set' do
        subject { build(:event, cabin_price: 10) }

        it { is_expected.to accept_values_for(:max_cabin_requests, nil, '', 10) }
        it { is_expected.not_to accept_values_for(:max_cabin_requests, 0, -1) }
      end

      context 'when cabin_price is not set' do
        subject { build(:event, cabin_price: nil) }

        it { is_expected.to accept_values_for(:max_cabin_requests, nil, '') }
        it { is_expected.not_to accept_values_for(:max_cabin_requests, 10) }
      end
    end
  end

  describe '#admin?' do
    subject { event.admin?(user) }

    let(:event) { build(:event) }

    describe 'site admin' do
      let(:user) { create(:user, :site_admin) }

      it { is_expected.to be true }
    end

    context 'when given a normal user' do
      let(:user) { build(:user) }

      it { is_expected.to be false }
    end

    context 'when given a event admin' do
      let(:event) { create(:event, :with_admins) }
      let(:user) { event.admins.first }

      it { is_expected.to be true }
    end

    context 'when given an admin of another event' do
      let(:another_event) { create(:event, :with_admins) }

      let(:user) { another_event.admins.first }

      it { is_expected.to be false }
    end
  end

  describe '#cabins_available?' do
    subject { event.cabins_available? }

    let(:event) { create(:event, cabin_price:, max_cabin_requests:) }

    let(:cabin_price) { nil }
    let(:max_cabin_requests) { nil }

    context 'when no cabin price is set' do
      let(:cabin_price) { nil }

      it { is_expected.to be false }
    end

    context 'when cabin price is set' do
      let(:cabin_price) { 100 }

      context 'when no maximum specified for the number of cabin requests' do
        let(:max_cabin_requests) { nil }

        it { is_expected.to be true }
      end

      context 'when a maximum is specified for the number of cabin requests' do
        let(:max_cabin_requests) { 10 }

        context 'when there are fewer cabins requested than the maximum' do
          it { is_expected.to be true }
        end

        context 'when the number of cabins requested has met or exceeded the maximum' do
          before do
            create(:ticket_request, event:, cabins: max_cabin_requests)
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  describe '#ticket_sales_open?' do
    subject { event.ticket_sales_open? }

    let(:start_time) { 1.day.from_now }
    let(:end_time) { 2.days.from_now }
    let(:ticket_sale_start_time) { nil }
    let(:ticket_sale_end_time) { nil }

    let(:event) do
      build(:event, start_time:, end_time:,
            ticket_sales_start_time: ticket_sale_start_time,
            ticket_sales_end_time:   ticket_sale_end_time)
    end

    context 'when the event has ended' do
      let(:start_time) { 2.days.ago }
      let(:end_time) { 1.day.ago }

      it { is_expected.to be false }
    end

    context 'when the ticket sale start time is specified' do
      context 'and the ticket sale start time has passed' do
        let(:ticket_sale_start_time) { 1.day.ago }

        context 'and the ticket sale end time is not specified' do
          it { is_expected.to be true }
        end

        context 'and the ticket sale end time has not passed' do
          let(:ticket_sale_end_time) { 1.day.from_now }

          it { is_expected.to be true }
        end

        context 'and the ticket sale end time has passed' do
          let(:ticket_sale_end_time) { 1.hour.ago }

          it { is_expected.to be false }
        end
      end

      context 'and the start time has not passed' do
        let(:ticket_sale_start_time) { 1.day.from_now }

        it { is_expected.to be false }
      end
    end

    context 'when the ticket sale start time is not specified' do
      context 'and the ticket sale end time is not specified' do
        it { is_expected.to be true }
      end

      context 'and the ticket sale end time is specified' do
        context 'and the ticket sale end time has passed' do
          let(:ticket_sale_end_time) { 1.day.ago }

          it { is_expected.to be false }
        end

        context 'and the ticket sale end time has not passed' do
          let(:ticket_sale_end_time) { 1.hour.from_now }

          it { is_expected.to be true }
        end
      end
    end
  end
end
