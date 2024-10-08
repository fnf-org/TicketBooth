class DropDeadTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :price_rules
  end
end
