class EventAddons < ActiveRecord::Migration[7.1]
  def change
    create_table :addons do |t|
      t.string :category, null: false
      t.string :name, null: false
      t.integer :default_price, null: false
      t.timestamps
    end

    create_table :events_addons do |t|
      t.references :event, index: true, foreign_key: true, null: false
      t.references :addon, index: true, foreign_key: true, null: false
      t.integer :price, null: false
      t.timestamps
    end
  end
end
