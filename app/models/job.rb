# frozen_string_literal: true

class Job < ActiveRecord::Base
  belongs_to :event
  has_many :time_slots, dependent: :destroy

  attr_accessible :description, :event_id, :name

  validates :event_id, presence: true,
                       numericality: { only_integer: true, greater_than: 0 }

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 512 }
end
