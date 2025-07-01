# frozen_string_literal: true

# == Schema Information
#
# Table name: event_addons
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  addon_id   :integer          not null
#  price      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_event_addons_on_addon_id  (addon_id)
#  index_event_addons_on_event_id  (event_id)
#

class EventAddon < ApplicationRecord
  belongs_to :addon
  belongs_to :event
  attr_accessible :id, :event_id, :addon_id, :price, :event, :addon

  before_validation :set_default_values

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  delegate :name, to: :addon
  delegate :category, to: :addon
  delegate :humanized_category, to: :addon

  def set_default_values
    self.price ||= addon.default_price
  end

  def category_and_name
    "#{humanized_category}: #{name} ($)"
  end
end
