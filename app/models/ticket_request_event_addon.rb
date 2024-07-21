# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_request_event_addons
#
#  id                :bigint           not null, primary key
#  quantity          :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  event_addon_id    :bigint           not null
#  ticket_request_id :bigint           not null
#
# Indexes
#
#  index_ticket_request_event_addons_on_event_addon_id     (event_addon_id)
#  index_ticket_request_event_addons_on_ticket_request_id  (ticket_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_addon_id => event_addons.id)
#  fk_rails_...  (ticket_request_id => ticket_requests.id)
#
class TicketRequestEventAddon < ApplicationRecord
  belongs_to :event_addon
  belongs_to :ticket_request

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

end
