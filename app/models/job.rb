# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id          :integer          not null, primary key
#  description :string(512)      not null
#  name        :string(100)      not null
#  created_at  :datetime
#  updated_at  :datetime
#  event_id    :integer          not null
#
class Job < ApplicationRecord
  belongs_to :event
  has_many :time_slots, dependent: :destroy

  attr_accessible :description, :event_id, :name

  validates :event_id,
            numericality: { only_integer: true, greater_than: 0 }

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 512 }
end
