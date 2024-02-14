# frozen_string_literal: true

class AddAskHowManyShiftsToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :ask_how_many_shifts, :boolean, default: false, null: false
  end
end
