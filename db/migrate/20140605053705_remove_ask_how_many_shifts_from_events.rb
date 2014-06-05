class RemoveAskHowManyShiftsFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :ask_how_many_shifts
  end
end
