class Event < ActiveRecord::Base
  attr_accessible :name, :start_time, :end_time

  validates :name, presence: true, length: { maximum: 100 }

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate  :end_time_after_start_time

private

  def end_time_after_start_time
    if end_time && end_time <= start_time
      errors.add(:end_time, 'must be after start time')
    end
  end
end
