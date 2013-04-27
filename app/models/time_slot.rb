class TimeSlot < ActiveRecord::Base
  belongs_to :job
  has_many :shifts, dependent: :destroy

  attr_accessible :end_time, :job_id, :slots, :start_time

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate  :end_time_after_start_time

  validates :job_id, presence: true, numericality: { only_integer: true },
    allow_nil: false
  validates :slots, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  def slots_left
    slots - shifts.count
  end

  def slots_left?
    slots_left > 0
  end

  def volunteered?(user)
    shifts.where(user_id: user.id).exists?
  end

private

  def end_time_after_start_time
    if end_time <= start_time
      errors.add(:end_time, 'must be after start time')
    end
  end
end
