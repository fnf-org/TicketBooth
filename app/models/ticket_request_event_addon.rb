# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_request_event_addons
#
#  id                 :bigint           not null, primary key
#  quantity           :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  event_addons_id    :bigint           not null
#  ticket_requests_id :bigint           not null
#
# Indexes
#
#  index_ticket_request_event_addons_on_event_addons_id     (event_addons_id)
#  index_ticket_request_event_addons_on_ticket_requests_id  (ticket_requests_id)
#
# Foreign Keys
#
#  fk_rails_...  (event_addons_id => event_addons.id)
#  fk_rails_...  (ticket_requests_id => ticket_requests.id)
#
class TicketRequestEventAddon < ApplicationRecord
  belongs_to :event_addon
  belongs_to :ticket_request
end
