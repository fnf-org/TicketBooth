# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_requests
#
#  id                      :bigint           not null, primary key
#  address_line1           :string(200)
#  address_line2           :string(200)
#  admin_notes             :string(512)
#  adults                  :integer          default(1), not null
#  agrees_to_terms         :boolean
#  cabins                  :integer          default(0), not null
#  car_camping             :boolean
#  car_camping_explanation :string(200)
#  city                    :string(50)
#  country_code            :string(4)
#  deleted_at              :datetime
#  donation                :decimal(8, 2)    default(0.0)
#  early_arrival_passes    :integer          default(0), not null
#  guests                  :text
#  kids                    :integer          default(0), not null
#  late_departure_passes   :integer          default(0), not null
#  needs_assistance        :boolean          default(FALSE), not null
#  notes                   :string(500)
#  previous_contribution   :string(250)
#  role                    :string           default("volunteer"), not null
#  role_explanation        :string(200)
#  special_price           :decimal(8, 2)
#  state                   :string(50)
#  status                  :string(1)        not null
#  zip_code                :string(32)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  event_id                :integer          not null
#  user_id                 :integer          not null
#
# Indexes
#
#  index_ticket_requests_on_deleted_at  (deleted_at) WHERE (deleted_at IS NULL)
#

require 'rails_helper'

describe TicketRequest do
  describe 'validations' do
    subject { ticket_request }

    describe '#user' do
      let(:ticket_request) { build(:ticket_request, user:) }

      context 'when not present' do
        let(:user) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when user exists' do
        let(:user) { build(:user) }

        it { is_expected.to be_valid }
      end

      context 'when the user has other ticket requests' do
        let(:event) { create(:event) }
        let(:user) { create(:user) }

        let(:ticket_request) { build(:ticket_request, event:, user:) }

        context 'and they already have a request for this event' do
          before { create(:ticket_request, event:, user:) }

          it { is_expected.to be_valid }
        end

        context 'and they have created requests only for other events' do
          before { create(:ticket_request, user:) }

          it { is_expected.to be_valid }
        end
      end
    end

    describe '#event' do
      let(:ticket_request) { build(:ticket_request, event:) }

      context 'when not present' do
        let(:event) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when event exists' do
        let(:event) { create(:event) }

        it { is_expected.to be_valid }
      end
    end

    describe '#adults' do
      let(:ticket_request) { build(:ticket_request, adults:) }

      context 'when not present' do
        let(:adults) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when not a number' do
        let(:adults) { 'not a number' }

        it { is_expected.not_to be_valid }
      end

      context 'when a number' do
        let(:adults) { 2 }

        it { is_expected.to be_valid }
      end
    end

    describe '#kids' do
      let(:ticket_request) { build(:ticket_request, kids:) }

      context 'when not present' do
        let(:kids) { nil }

        it { is_expected.to be_valid }
      end

      context 'when not a number' do
        let(:kids) { 'not a number' }

        it { is_expected.not_to be_valid }
      end

      context 'when a number' do
        let(:kids) { 2 }

        it { is_expected.to be_valid }
      end
    end

    describe '#cabins' do
      let(:ticket_request) { build(:ticket_request, cabins:) }

      context 'when not present' do
        let(:cabins) { nil }

        it { is_expected.to be_valid }
      end

      context 'when not a number' do
        let(:cabins) { 'not a number' }

        it { is_expected.not_to be_valid }
      end

      context 'when a number' do
        let(:cabins) { 2 }

        it { is_expected.to be_valid }
      end
    end

    describe '#notes' do
      let(:ticket_request) { build(:ticket_request, notes:) }

      context 'when not present' do
        let(:notes) { nil }

        it { is_expected.to be_valid }
      end

      context 'when longer than 500 characters' do
        let(:notes) { Faker::Alphanumeric.alpha(number: 501) }

        it { is_expected.not_to be_valid }
      end

      describe 'normalization' do
        subject { build(:ticket_request) }

        it { is_expected.to normalize(:notes) }

        it { is_expected.to normalize(:notes).from(' Blah ').to('Blah') }

        it { is_expected.to normalize(:notes).from('Blah  Blah').to('Blah Blah') }
      end
    end

    describe '#special_price' do
      let(:ticket_request) { create(:ticket_request, special_price:) }

      context 'when not present' do
        let(:special_price) { nil }

        it { is_expected.to be_valid }
      end
    end
  end

  describe '#create' do
    let(:ticket_request) { create(:ticket_request, event:) }

    context 'when the event requires approval for tickets' do
      let(:event) { create(:event, tickets_require_approval: true) }

      it 'sets the default status to pending' do
        ticket_request.status.should == TicketRequest::STATUS_PENDING
      end
    end

    context 'when the event does not require approval for tickets' do
      let(:event) { create(:event, tickets_require_approval: false) }

      it 'sets the default status to awaiting payment' do
        ticket_request.status.should == TicketRequest::STATUS_AWAITING_PAYMENT
      end
    end
  end

  describe '#can_view?' do
    subject { create(:ticket_request, user: requester).can_view?(user) }

    let(:requester) { create(:user) }

    context 'when the user is a site admin' do
      let(:user) { create(:site_admin).user }

      it { is_expected.to be true }
    end

    context 'when the user is the ticket request creator' do
      let(:user) { requester }

      it { is_expected.to be true }
    end

    context 'when the user is anybody else' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe '#pending?' do
    context 'when the ticket request is pending' do
      subject { create(:ticket_request, status: TicketRequest::STATUS_PENDING) }

      it { is_expected.to be_pending }
    end
  end

  describe '#approved?' do
    context 'when the ticket request is approved' do
      subject { create(:ticket_request, status: TicketRequest::STATUS_AWAITING_PAYMENT) }

      it { is_expected.to be_approved }
    end
  end

  describe '#approve' do
    subject { create(:ticket_request, special_price: price, status: TicketRequest::STATUS_PENDING) }

    before { subject.approve }

    context 'when the ticket request has a price of zero dollars' do
      let(:price) { 0 }

      it { is_expected.to be_completed }
    end

    context 'when the ticket request has a price greater than zero dollars' do
      let(:price) { 10 }

      it { is_expected.to be_approved }
    end
  end

  describe '#declined?' do
    context 'when the ticket request is declined' do
      subject { build(:ticket_request, status: TicketRequest::STATUS_DECLINED) }

      it { is_expected.to be_declined }
    end
  end

  describe '#price' do
    subject { ticket_request.price }

    let(:adult_price) { 10 }
    let(:adults) { 2 }
    let(:kid_price) { nil }
    let(:kids) { nil }
    let(:cabin_price) { nil }
    let(:cabins) { nil }
    let(:special_price) { nil }
    let(:event) do
      build(:event,
            adult_ticket_price: adult_price,
            kid_ticket_price:   kid_price,
            cabin_price:)
    end
    let(:ticket_request) do
      build(:ticket_request,
            event:,
            adults:,
            kids:,
            cabins:,
            special_price:)
    end

    context 'when kid ticket price is not set on the event' do
      it { is_expected.to eql(adult_price * adults) }
    end

    context 'when the ticket request includes kids' do
      let(:kids) { 2 }
      let(:kid_price) { 10 }

      it { is_expected.to eql((adult_price * adults) + (kid_price * kids)) }
    end

    context 'when the ticket request does not include kids' do
      let(:kids) { nil }

      it { is_expected.to eql(adult_price * adults) }
    end

    context 'when the ticket request includes cabins' do
      let(:cabins) { 2 }
      let(:cabin_price) { 100 }

      it { is_expected.to eql((adult_price * adults) + (cabin_price * cabins)) }
    end

    context 'when the ticket request does not include cabins' do
      let(:cabins) { nil }

      it { is_expected.to eql(adult_price * adults) }
    end

    context 'when a special price is set' do
      let(:special_price) { BigDecimal(99.99, 10) }

      it { is_expected.to eql(special_price) }
    end

    context 'when custom price rules are defined' do
      let(:kid_price) { 10 }
      let(:trigger_value) { 3 }
      let(:custom_price) { 5 }

      before do
        PriceRule::KidsEqualTo.create! event:,
                                       trigger_value:,
                                       price: custom_price
      end

      context 'and the rule does not apply' do
        let(:kids) { trigger_value - 1 }

        it { is_expected.to eql((adult_price * adults) + (kid_price * kids)) }
      end

      context 'and the rule applies' do
        let(:kids) { trigger_value }

        it { is_expected.to eql((adult_price * adults) + 5) }
      end
    end
  end

  describe '#total_tickets' do
    subject(:ticket_request) { create(:ticket_request, adults: 3, kids: 2) }

    its(:total_tickets) { is_expected.to be(5) }
  end

  describe '#guests' do
    subject(:ticket_request) { create(:ticket_request, guests:) }

    let(:guests) do
      [
        'Carl Cox <carl@cox.com>',
        'John Dig Meet <digweed@bedrock-records.com'
      ]
    end

    its(:guests) { is_expected.to be_a(Array) }

    describe 'adding a guest' do
      before do
        ticket_request.guests << 'DJ Ass <asswipe@trainwreck-records.com>'
        ticket_request.save!
      end

      its('guests.size') { is_expected.to be(3) }

      describe 'raw field' do
        let(:raw_guests) { described_class.connection.execute("select guests from ticket_requests where id = '#{ticket_request.id}'")[0]['guests'] }

        it 'stores guests as a string' do
          expect(raw_guests).to be_a(String)
        end

        describe 'parsed array' do
          subject { YAML.load(raw_guests) }

          it { is_expected.to be_a(Array) }

          its(:size) { is_expected.to be 3 }
        end
      end
    end

    describe '#guest_list' do
      subject { ticket_request.guest_list }

      it { is_expected.to be_a(Array) }

      its(:size) { is_expected.to be(3) }

      its(:first) { is_expected.to eq(ticket_request.user.name_and_email) }
    end
  end

  describe '.for_csv' do
    let(:event) { create(:event) }
    let(:number_of_active_requests) { 5 }
    let(:number_of_inactive_requests) { 2 }

    let(:guest_list) { ['Konstantin Gredeskoul <kig@fnf.org>', 'Matt Levy <matt@fnf.org>'] }

    before do
      # These are completed
      (number_of_active_requests - 2).times do |_index|
        event.ticket_requests.create!(user: create(:user), agrees_to_terms: true, status: TicketRequest::STATUS_COMPLETED, guests: guest_list)
      end

      # These are still waiting on the payment
      (number_of_active_requests - 3).times do
        event.ticket_requests.create!(user: create(:user), agrees_to_terms: true, status: TicketRequest::STATUS_AWAITING_PAYMENT, guests: guest_list)
      end

      # These should not be included in the CSV, as they have not been approved
      number_of_inactive_requests.times do
        event.ticket_requests.create!(user: create(:user), agrees_to_terms: true, status: TicketRequest::STATUS_PENDING, guests: guest_list)
      end
    end

    describe 'event with active requests' do
      subject { described_class.for_csv(event) }

      it 'has the right number of total ticket requests' do
        expect(event.ticket_requests.size).to eq(number_of_active_requests + number_of_inactive_requests)
      end

      it 'has the right number of active ticket requests' do
        expect(event.ticket_requests.active.size).to eq(number_of_active_requests)
      end

      it 'each request should have two guests' do
        event.ticket_requests.each do |tr|
          expect(tr.guests.size).to eq(2)
        end
      end

      it { is_expected.to be_a(Array) }

      it { is_expected.not_to eq [] }

      # number of active requests with two guests each
      its(:size) { is_expected.to eq(number_of_active_requests) }
    end

    describe '.csv_columns' do
      subject { described_class.csv_header }

      it { is_expected.to start_with %w[name email id adults kids] }
    end
  end
end
