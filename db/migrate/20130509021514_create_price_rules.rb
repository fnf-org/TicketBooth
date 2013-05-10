class CreatePriceRules < ActiveRecord::Migration
  def change
    create_table :price_rules do |t|
      t.string :type
      t.references :event
      t.decimal :price, precision: 8, scale: 2
      t.integer :trigger_value

      t.timestamps
    end

    add_index :price_rules, :event_id
  end
end
