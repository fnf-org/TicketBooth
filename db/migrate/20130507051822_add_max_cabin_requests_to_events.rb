class AddMaxCabinRequestsToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.integer :max_cabin_requests
    end
  end
end
