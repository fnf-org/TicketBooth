# frozen_string_literal: true

# == Schema Information
#
# Table name: shifts
#
#  id           :bigint           not null, primary key
#  name         :string(70)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  time_slot_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_shifts_on_time_slot_id  (time_slot_id)
#  index_shifts_on_user_id       (user_id)
#
class Shift < ApplicationRecord
  belongs_to :time_slot
  belongs_to :user

  attr_accessible :name, :time_slot_id, :user_id

  validates :name, length: { in: 3..User::MAX_NAME_LENGTH },
                   allow_nil: true, allow_blank: false

  validates :time_slot_id,
            numericality: { only_integer: true, greater_than: 0 }

  validates :user_id,
            numericality: { only_integer: true, greater_than: 0 }

  def volunteer_name
    self[:name] || user.name
  end
end
