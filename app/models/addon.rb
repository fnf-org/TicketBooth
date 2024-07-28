# frozen_string_literal: true

# == Schema Information
#
# Table name: addons
#
#  id            :bigint           not null, primary key
#  category      :string           not null
#  default_price :integer          not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Addon < ApplicationRecord
  has_many :event_addons, autosave: true, dependent: :destroy
  has_many :ticket_request_event_addon, autosave: true, dependent: :destroy

  CATEGORIES = [CATEGORY_PASS = 'pass',
                CATEGORY_CAMP = 'camp'].freeze

  HUMANIZED_CATEGORIES = {
    CATEGORY_PASS => 'Passes',
    CATEGORY_CAMP => 'Camping'
  }.freeze

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :name, presence: true
  validates :default_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.categories
    CATEGORIES
  end

  def humanized_category
    HUMANIZED_CATEGORIES[category]
  end

  def self.order_by_category
    order(:category, :id)
  end

  def self.find_all_by_category(category)
    addons = []

    where(category:).find_each do |addon|
      addons << addon
    end

    addons
  end
end
