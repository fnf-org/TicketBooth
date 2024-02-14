# frozen_string_literal: true

class CreateTimeSlots < ActiveRecord::Migration[6.0]
  def change
    create_table :time_slots do |t|
      t.belongs_to :job, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :slots, null: false

      t.timestamps
    end
  end
end
