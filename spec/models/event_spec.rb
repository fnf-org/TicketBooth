# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                            :bigint           not null, primary key
#  adult_ticket_price            :integer
#  allow_donations               :boolean          default(FALSE), not null
#  allow_financial_assistance    :boolean          default(FALSE), not null
#  end_time                      :datetime
#  kid_ticket_price              :integer
#  max_adult_tickets_per_request :integer
#  max_kid_tickets_per_request   :integer
#  name                          :string
#  photo                         :string
#  require_mailing_address       :boolean          default(FALSE), not null
#  require_role                  :boolean          default(TRUE), not null
#  slug                          :text
#  start_time                    :datetime
#  ticket_requests_end_time      :datetime
#  ticket_sales_end_time         :datetime
#  ticket_sales_start_time       :datetime
#  tickets_require_approval      :boolean          default(TRUE), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

require 'rails_helper'

RSpec.describe Event do
  subject(:event) { build(:event, **params) }

  let(:params) { {} }

  it { is_expected.to be_valid }

  describe '#to_param' do
    context 'given an event that exists in the database' do
      subject(:event) { create(:event, name: 'Summer Campout XII') }

      its(:to_param) { is_expected.to eq "#{event.id}-summer-campout-xii" }
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
    # Must use UTC timezone to avoid day-light-savings off by one failure
    let(:params) { { start_time: TimeHelper.from_flatpickr('10/1/2030, 12:00 PM UTC') } }

    describe '#starting' do
      subject { event.starting.to_s }

      it { is_expected.to eq 'Tuesday, October 1, 2030 @ 05:00 AM' }
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

      context 'scope #sales_open' do
        subject { described_class.sales_open.first }

        before { event.save! }

        let(:ticket_sale_start_time) { 1.day.ago }

        it { is_expected.to eq event }
      end

      context 'scope #live_event' do
        subject { described_class.live_events.first }

        before { event.save! }

        describe 'when it exists' do
          let(:ticket_sale_start_time) { 1.day.ago }
          let(:start_time) { 1.day.from_now }

          it { is_expected.to eq event }
        end

        describe 'when it does not exist' do
          let(:ticket_sale_start_time) { 1.day.from_now }
          let(:start_time) { 1.month.from_now }
          let(:end_time) { 1.month.from_now + 2.days }

          it { is_expected.to be_nil }
        end
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

  describe '#build_event_addons_from_params' do
    let(:price) { 314 }

    context 'event addon is built for event' do
      let!(:addon) { create(:addon) }

      before do
        event_addons_attributes = { '0'=>{ 'addon_id' => addon.id.to_s, 'price' => price.to_s } }
        event.build_event_addons_from_params(event_addons_attributes)
      end

      it 'has 1 event addon' do
        expect(event.event_addons.size).to eq(1)
      end

      it 'has price set from params' do
        expect(event.event_addons.first&.price).to eq(price)
      end

      it 'has addon id set from params' do
        expect(event.event_addons.first&.addon_id).to eq(addon.id)
      end
    end

    context 'event addon is not built for event' do
      before do
        event_addons_attributes = { '0'=>{ 'addon_id' => 999, 'price' => price.to_s } }
        event.build_event_addons_from_params(event_addons_attributes)
      end

      it 'has an unknown addon id' do
        expect(event.event_addons.size).to eq(0)
      end
    end
  end

  describe '#create_default_event_addons' do
    context 'event has no addons' do
      it 'event has no addons' do
        expect(event.event_addons.count).to eq(0)
      end
    end

    context 'event has event addons' do
      before do
        create(:addon)
        event.create_default_event_addons
      end

      it 'creates and persists an EventAddon' do
        expect(EventAddon.count).to eq(1)
      end

      it 'creates EventAddon with name' do
        expect(EventAddon.first&.name).to eq(Addon.first.name)
      end

      it 'event has event addons for each Addon' do
        expect(event.event_addons.size).to eq(Addon.count)
      end

      it 'event has default prices for addons' do
        event_addon = event.event_addons.first
        expect(event_addon&.price).to eq(event_addon&.addon&.default_price)
      end
    end
  end

  describe '#load_default_event_addons' do
    context 'event has no addons' do
      it 'event has no addons' do
        expect(event.event_addons.count).to eq(0)
      end
    end

    context 'event has event addons' do
      before do
        create(:addon)
        event.build_default_event_addons
      end

      it 'event has event addons for each Addon' do
        expect(event.event_addons.size).to eq(Addon.count)
      end

      it 'event addons are not saved' do
        expect(event.event_addons.first&.persisted?).to be_falsey
      end
    end
  end

  describe '#active_event_addons' do
    let!(:event) { create(:event) }
    let!(:event_addon) { create(:event_addon, event_id: event.id) }

    it 'has a price not 0' do
      expect(event_addon.price).not_to eq(0)
    end

    it 'finds one active event' do
      expect(event.active_event_addons.count).to eq(1)
    end
  end
end
