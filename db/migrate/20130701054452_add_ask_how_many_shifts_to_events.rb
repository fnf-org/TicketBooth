class AddAskHowManyShiftsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :ask_how_many_shifts, :boolean, default: false, null: false
  end
end
