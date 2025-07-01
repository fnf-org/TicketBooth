# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_request_event_addons
#
#  id                :integer          not null, primary key
#  ticket_request_id :integer          not null
#  event_addon_id    :integer          not null
#  quantity          :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_ticket_request_event_addons_on_event_addon_id     (event_addon_id)
#  index_ticket_request_event_addons_on_ticket_request_id  (ticket_request_id)
#

require 'rails_helper'

RSpec.describe TicketRequestEventAddon, type: :model do
  describe 'validations' do
    subject { ticket_request_event_addon }

    let(:ticket_request_event_addon) { build(:ticket_request_event_addon) }

    describe '#quantity' do
      context 'when valid quantity' do
        let(:ticket_request_event_addon) { build(:ticket_request_event_addon, quantity: 2) }

        it { is_expected.to be_valid }
      end

      context 'when invalid quantity' do
        let(:ticket_request_event_addon) { build(:ticket_request_event_addon, quantity: -1) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
