# frozen_string_literal: true

class CreatePriceRules < ActiveRecord::Migration[6.0]
  def change
    create_table :price_rules do |t|
      t.string :type
      t.references :event
      t.decimal :price, precision: 8, scale: 2
      t.integer :trigger_value

      t.timestamps
    end
  end
end
