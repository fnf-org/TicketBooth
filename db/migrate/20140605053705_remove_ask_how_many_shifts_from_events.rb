# frozen_string_literal: true

class RemoveAskHowManyShiftsFromEvents < ActiveRecord::Migration[6.0]
  def change
    remove_column :events, :ask_how_many_shifts
  end
end
