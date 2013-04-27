class EventAdmin < ActiveRecord::Base
  attr_accessible :event_id, :user_id

  belongs_to :event
  belongs_to :user

  validates :event_id, existence: true

  validates :user_id, existence: true,
    uniqueness: { scope: :event_id, message: 'already admin for this event' }
end
