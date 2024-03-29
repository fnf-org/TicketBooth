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
describe TicketRequest do
  describe 'validations' do
    subject { ticket_request }

    describe '#user' do
      let(:ticket_request) { described_class.make user: }

      context 'when not present' do
        let(:user) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when user exists' do
        let(:user) { User.make! }

        it { is_expected.to be_valid }
      end

      context 'when user is new' do
        let(:user) { User.make }

        it { is_expected.to be_valid }
      end

      context 'when the user has other ticket requests' do
        let(:event) { Event.make! }
        let(:user) { User.make! }
        let(:ticket_request) { described_class.make event:, user: }

        context 'and they already have a request for this event' do
          before do
            described_class.make! event:, user:
          end

          # TODO: Decide whether we would rather allow editing of ticket
          # requests instead of making multiple requests
          it { is_expected.to be_valid }
        end

        context 'and they have created requests only for other events' do
          before do
            described_class.make user:
          end

          it { is_expected.to be_valid }
        end
      end
    end

    describe '#event' do
      let(:ticket_request) { described_class.make event: }

      context 'when not present' do
        let(:event) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when event exists' do
        let(:event) { Event.make! }

        it { is_expected.to be_valid }
      end
    end

    describe '#adults' do
      let(:ticket_request) { described_class.make adults: }

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
      let(:ticket_request) { described_class.make kids: }

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
      let(:ticket_request) { described_class.make cabins: }

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
      let(:ticket_request) { described_class.make notes: }

      context 'when not present' do
        let(:notes) { nil }

        it { is_expected.to be_valid }
      end

      context 'when longer than 500 characters' do
        let(:notes) { Sham.string(501) }

        it { is_expected.not_to be_valid }
      end

      describe 'normalization' do
        subject { described_class.new }

        it { is_expected.to normalize(:notes) }
        it { is_expected.to normalize(:notes).from(' Blah ').to('Blah') }
        it { is_expected.to normalize(:notes).from('Blah  Blah').to('Blah Blah') }
      end
    end

    describe '#special_price' do
      let(:ticket_request) { described_class.make special_price: }

      context 'when not present' do
        let(:special_price) { nil }

        it { is_expected.to be_valid }
      end
    end
  end

  describe '#create' do
    let(:ticket_request) { described_class.make! event: }

    context 'when the event requires approval for tickets' do
      let(:event) { Event.make! tickets_require_approval: true }

      it 'sets the default status to pending' do
        ticket_request.status.should == TicketRequest::STATUS_PENDING
      end
    end

    context 'when the event does not require approval for tickets' do
      let(:event) { Event.make! tickets_require_approval: false }

      it 'sets the default status to awaiting payment' do
        ticket_request.status.should == TicketRequest::STATUS_AWAITING_PAYMENT
      end
    end
  end

  describe '#can_view?' do
    subject { described_class.make(user: requester).can_view?(user) }

    let(:requester) { User.make! }

    context 'when the user is a site admin' do
      let(:user) { User.make! :site_admin }

      it { is_expected.to be true }
    end

    context 'when the user is the ticket request creator' do
      let(:user) { requester }

      it { is_expected.to be true }
    end

    context 'when the user is anybody else' do
      let(:user) { User.make! }

      it { is_expected.to be false }
    end
  end

  describe '#pending?' do
    context 'when the ticket request is pending' do
      subject { described_class.make(:pending).pending? }

      it { is_expected.to be true }
    end
  end

  describe '#approved?' do
    context 'when the ticket request is approved' do
      subject { described_class.make(:approved).approved? }

      it { is_expected.to be true }
    end
  end

  describe '#approve' do
    subject { described_class.make(:pending, special_price: price) }

    before do
      subject.approve
    end

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
      subject { described_class.make(:declined).declined? }

      it { is_expected.to be true }
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
      Event.make!(
        adult_ticket_price: adult_price,
        kid_ticket_price: kid_price,
        cabin_price:
      )
    end
    let(:ticket_request) do
      described_class.make(
        event:,
        adults:,
        kids:,
        cabins:,
        special_price:
      )
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
    it 'is the sum of the number of adults and children' do
      described_class.make(adults: 3, kids: 2).total_tickets == 5
    end
  end
end
