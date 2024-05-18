# frozen_string_literal: true

# == Schema Information
#
# Table name: shifts
#
#  id           :integer          not null, primary key
#  name         :string(70)
#  created_at   :datetime
#  updated_at   :datetime
#  time_slot_id :integer          not null
#  user_id      :integer          not null
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
