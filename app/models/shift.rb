class Shift < ActiveRecord::Base
  belongs_to :time_slot, include: :job
  belongs_to :user

  attr_accessible :name, :time_slot_id, :user_id

  validates :name, length: { in: 2..70 }, allow_nil: true, allow_blank: false

  validates :time_slot_id, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  validates :user_id, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  def volunteer_name
    self[:name] || user.name
  end
end
