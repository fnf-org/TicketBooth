class ExtractAddressIntoMultipleFields < ActiveRecord::Migration
  def change
    remove_column :ticket_requests, :address

    change_table :ticket_requests do |t|
      t.string :address_line1, limit: 200, null: true
      t.string :address_line2, limit: 200, null: true
      t.string :city,          limit: 50,  null: true
      t.string :state,         limit: 50,  null: true
      t.string :zip_code,      limit: 32,  null: true
      t.string :country_code,  limit: 4,   null: true
    end
  end
end
