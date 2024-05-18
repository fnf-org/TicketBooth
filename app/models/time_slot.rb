# frozen_string_literal: true

# == Schema Information
#
# Table name: time_slots
#
#  id         :integer          not null, primary key
#  end_time   :datetime         not null
#  slots      :integer          not null
#  start_time :datetime         not null
#  created_at :datetime
#  updated_at :datetime
#  job_id     :integer          not null
#
class TimeSlot < ApplicationRecord
  belongs_to :job
  has_many :shifts, dependent: :destroy

  attr_accessible :end_time, :job, :job_id, :slots, :start_time

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate  :end_time_after_start_time

  validates :job_id, numericality: { only_integer: true },
                     allow_nil: false
  validates :slots, presence: true,
                    numericality: { only_integer: true, greater_than: 0 }

  def slots_left
    slots - shifts.size
  end

  def slots_left?
    slots_left.positive?
  end

  def volunteered?(user)
    shifts.any? { |shift| shift.user == user }
  end

  private

  def end_time_after_start_time
    errors.add(:end_time, 'must be after start time') if end_time <= start_time
  end
end
