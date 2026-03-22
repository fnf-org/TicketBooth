# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                            :integer          not null, primary key
#  name                          :string
#  start_time                    :datetime
#  end_time                      :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  adult_ticket_price            :integer
#  kid_ticket_price              :integer
#  max_adult_tickets_per_request :integer
#  max_kid_tickets_per_request   :integer
#  photo                         :string
#  tickets_require_approval      :boolean          default(TRUE), not null
#  require_mailing_address       :boolean          default(FALSE), not null
#  allow_financial_assistance    :boolean          default(FALSE), not null
#  allow_donations               :boolean          default(FALSE), not null
#  ticket_sales_start_time       :datetime
#  ticket_sales_end_time         :datetime
#  ticket_requests_end_time      :datetime
#  slug                          :text
#  require_role                  :boolean          default(TRUE), not null
#  secret_token                  :string
#
# Indexes
#
#  index_events_on_secret_token  (secret_token) UNIQUE
#

require 'rails_helper'

RSpec.describe Event do
  subject(:event) { build(:event, **params) }

  let(:params) { {} }

  it { is_expected.to be_valid }

  describe '#to_param' do
    context 'given an event with a secret_token' do
      subject(:event) { create(:event, name: 'Summer Campout XII') }

      it 'uses secret_token-slug format' do
        expect(event.secret_token).to be_present
        expect(event.to_param).to eq "#{event.secret_token}-summer-campout-xii"
      end
    end

    context 'given an event without a secret_token' do
      subject(:event) { create(:event, name: 'Summer Campout XII') }

      it 'falls back to id-slug format' do
        event.update_column(:secret_token, nil)
        expect(event.to_param).to eq "#{event.id}-summer-campout-xii"
      end
    end
  end

  describe '#generate_secret_token!' do
    subject(:event) { create(:event) }

    it 'auto-generates an 8-character lowercase alphanumeric token on create' do
      expect(event.secret_token).to match(/\A[a-z0-9]{8}\z/)
    end

    it 'generates unique tokens' do
      tokens = 10.times.map { create(:event).secret_token }
      expect(tokens.uniq.length).to eq 10
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

  describe '#status' do
    subject { event.status }

    context 'when event is in the past' do
      let(:event) { build(:event, start_time: 2.weeks.ago, end_time: 1.week.ago) }

      its(:name) { is_expected.to eq 'Past Event' }
      its(:css_class) { is_expected.to eq 'secondary' }
    end

    context 'when ticket sales are open' do
      let(:event) do
        build(:event,
              start_time: 1.week.from_now,
              end_time: 2.weeks.from_now,
              ticket_sales_start_time: 1.day.ago,
              ticket_sales_end_time: 1.week.from_now)
      end

      its(:name) { is_expected.to eq 'On Sale' }
      its(:css_class) { is_expected.to eq 'success' }
    end

    context 'when ticket requests are open but sales are not' do
      let(:event) do
        build(:event,
              start_time: 1.week.from_now,
              end_time: 2.weeks.from_now,
              ticket_sales_start_time: 1.day.ago,
              ticket_sales_end_time: nil,
              ticket_requests_end_time: 1.week.from_now)
      end

      its(:name) { is_expected.to eq 'On Sale' }
    end

    context 'when event is in the future with no sales window' do
      let(:event) do
        build(:event,
              start_time: 6.months.from_now,
              end_time: 6.months.from_now + 1.day,
              ticket_sales_start_time: 3.months.from_now,
              ticket_sales_end_time: 5.months.from_now,
              ticket_requests_end_time: 5.months.from_now)
      end

      its(:name) { is_expected.to eq 'A Future Event' }
      its(:css_class) { is_expected.to eq 'warning' }
    end
  end

  describe '#ticket_requests_open?' do
    subject { event.ticket_requests_open? }

    context 'when ticket_requests_end_time has passed' do
      let(:event) do
        build(:event,
              start_time: 1.week.from_now,
              end_time: 2.weeks.from_now,
              ticket_requests_end_time: 1.day.ago)
      end

      it { is_expected.to be false }
    end

    context 'when event has ended' do
      let(:event) { build(:event, start_time: 2.weeks.ago, end_time: 1.day.ago) }

      it { is_expected.to be false }
    end

    context 'when ticket sales have not started yet' do
      let(:event) do
        build(:event,
              start_time: 1.week.from_now,
              end_time: 2.weeks.from_now,
              ticket_sales_start_time: 1.day.from_now)
      end

      it { is_expected.to be false }
    end

    context 'when tickets are available for request' do
      let(:event) do
        build(:event,
              start_time: 1.week.from_now,
              end_time: 2.weeks.from_now,
              ticket_sales_start_time: 1.day.ago,
              ticket_requests_end_time: 1.week.from_now)
      end

      it { is_expected.to be true }
    end
  end

  describe '#past_event?' do
    subject { event.past_event? }

    context 'when event has ended' do
      let(:event) { build(:event, start_time: 2.weeks.ago, end_time: 1.day.ago) }

      it { is_expected.to be true }
    end

    context 'when event has not ended' do
      let(:event) { build(:event, start_time: 1.week.from_now, end_time: 2.weeks.from_now) }

      it { is_expected.to be false }
    end
  end

  describe '#future_event?' do
    subject { event.future_event? }

    context 'when event has not started' do
      let(:event) { build(:event, start_time: 1.week.from_now, end_time: 2.weeks.from_now) }

      it { is_expected.to be true }
    end

    context 'when event has already started' do
      let(:event) { build(:event, start_time: 1.day.ago, end_time: 1.week.from_now) }

      it { is_expected.to be false }
    end
  end

  describe '#revenue' do
    let(:event) { create(:event) }

    context 'when there are no completed ticket requests' do
      it { expect(event.revenue).to be_empty }
    end

    context 'when there are completed ticket requests with payments' do
      let!(:tr) { create(:ticket_request, :completed, event:) }
      let!(:payment) { create(:payment, ticket_request: tr, status: :received) }

      it 'returns payment objects' do
        expect(event.revenue).to include(payment)
      end
    end
  end

  describe '#make_admin' do
    let(:event) { create(:event) }
    let(:user) { create(:user) }

    context 'when user is not already an admin' do
      it 'creates an EventAdmin record' do
        expect { event.make_admin(user) }.to change(EventAdmin, :count).by(1)
      end
    end

    context 'when user is already an admin' do
      before { event.make_admin(user) }

      it 'returns false' do
        expect(event.make_admin(user)).to be false
      end
    end

    context 'when user is a site admin' do
      let(:user) { create(:user, :site_admin) }

      it 'returns false because site admins are already admins' do
        expect(event.make_admin(user)).to be false
      end
    end
  end

  describe '#admin_contacts' do
    subject { event.admin_contacts }

    let(:event) { create(:event, :with_admins) }

    it { is_expected.to be_a(Array) }

    it 'returns name_and_email strings' do
      expect(subject.first).to match(/<.+@.+>/)
    end
  end

  describe '#to_param' do
    context 'when event is not persisted' do
      subject { build(:event).to_param }

      it { is_expected.to be_nil }
    end
  end

  describe '#admissible_requests' do
    subject { event.admissible_requests }

    let(:event) { create(:event) }

    let!(:completed_tr) { create(:ticket_request, :completed, event:) }
    let!(:pending_tr) { create(:ticket_request, :pending, event:) }
    let!(:awaiting_tr) { create(:ticket_request, :approved, event:) }
    let!(:declined_tr) { create(:ticket_request, :declined, event:) }

    it 'includes completed, awaiting payment, and pending requests' do
      expect(subject).to include(completed_tr, pending_tr, awaiting_tr)
    end

    it 'excludes declined requests' do
      expect(subject).not_to include(declined_tr)
    end
  end
end
