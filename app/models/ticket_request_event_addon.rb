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

  attr_accessible :id, :event_addon_id, :ticket_request_id, :quantity, :event_addon, :ticket_request

  PURCHASE_CATEGORIES = {
    Addon::CATEGORY_PASS => 'Passes',
    Addon::CATEGORY_CAMP => 'Permits'
  }.freeze

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  delegate :name, to: :event_addon
  delegate :price, to: :event_addon
  delegate :category, to: :event_addon
  delegate :humanized_category, to: :event_addon

  def set_default_values
    self.quantity ||= 0
  end

  def calculate_cost
    price * quantity
  end

  def purchase_category(category)
    PURCHASE_CATEGORIES[category]
  end

  def name_category_price_each
    "#{name} #{purchase_category(category)} @ $#{price} each"
  end
end
