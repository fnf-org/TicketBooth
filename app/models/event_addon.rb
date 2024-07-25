# frozen_string_literal: true

# == Schema Information
#
# Table name: event_addons
#
#  id         :bigint           not null, primary key
#  price      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  addon_id   :bigint           not null
#  event_id   :bigint           not null
#
# Indexes
#
#  index_event_addons_on_addon_id  (addon_id)
#  index_event_addons_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (addon_id => addons.id)
#  fk_rails_...  (event_id => events.id)
#
class EventAddon < ApplicationRecord
  belongs_to :addon
  belongs_to :event
  attr_accessible :id, :event_id, :addon_id, :price, :event, :addon

  before_validation :set_default_values

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  delegate :name, to: :addon
  delegate :category, to: :addon

  def set_default_values
    self.price ||= addon.default_price
  end
end
