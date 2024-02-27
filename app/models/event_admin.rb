# frozen_string_literal: true

# == Schema Information
#
# Table name: event_admins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_event_admins_on_event_id              (event_id)
#  index_event_admins_on_event_id_and_user_id  (event_id,user_id) UNIQUE
#  index_event_admins_on_user_id               (user_id)
#  index_event_admins_on_user_id_only          (user_id)
#
class EventAdmin < ApplicationRecord
  attr_accessible :event_id, :user_id

  belongs_to :event
  belongs_to :user

  validates :user_id,
            uniqueness: { scope: :event_id, message: 'already admin for this event' }
end
