# frozen_string_literal: true

# == Schema Information
#
# Table name: jobs
#
#  id          :integer          not null, primary key
#  event_id    :integer          not null
#  name        :string(100)      not null
#  description :string(512)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_jobs_on_event_id  (event_id)
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
