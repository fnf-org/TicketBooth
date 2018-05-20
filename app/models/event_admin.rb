class EventAdmin < ActiveRecord::Base
  attr_accessible :event_id, :user_id

  belongs_to :event
  belongs_to :user

  validates :event_id, presence: true

  validates :user_id, presence: true,
    uniqueness: { scope: :event_id, message: 'already admin for this event' }
end
