class CreateTicketRequests < ActiveRecord::Migration
  def change
    create_table :ticket_requests do |t|
      t.string :name, limit: 70, null: false
      t.string :email, limit: 254, null: false
      t.string :address, limit: 150, null: false
      t.integer :adults, default: 1, null: false
      t.integer :kids, default: 0, null: false
      t.integer :cabins, default: 0, null: false
      t.boolean :assistance, default: false, null: false
      t.string :notes, limit: 500, null: true
      t.string :status, limit: 1, default: 'P', null: false

      t.timestamps
    end
  end
end
