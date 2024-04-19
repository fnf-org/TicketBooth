# frozen_string_literal: true

class CreateShifts < ActiveRecord::Migration[6.0]
  def change
    create_table :shifts do |t|
      t.belongs_to :time_slot, null: false
      t.belongs_to :user, null: false
      t.string :name, limit: 70, null: true

      t.timestamps
    end
  end
end
