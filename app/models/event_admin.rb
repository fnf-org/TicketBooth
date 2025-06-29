# frozen_string_literal: true

# == Schema Information
#
# Table name: event_admins
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_event_admins_on_event_id_and_user_id  (event_id,user_id) UNIQUE
#  index_event_admins_on_user_id               (user_id)
#

class EventAdmin < ApplicationRecord
  attr_accessible :event_id, :user_id

  belongs_to :event
  belongs_to :user

  validates :user_id,
            uniqueness: { scope: :event_id, message: 'already admin for this event' }

  validate do |record|
    raise ArgumentError, 'event_id is nil' if record.event_id.nil?
    raise ArgumentError, 'user_id is nil' if record.user_id.nil?
  end
end
