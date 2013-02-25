class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :ticket_request_id, null: false
      t.string  :stripe_charge_id, limit: 255, null: true
      t.string  :status, limit: 1, null: false, default: 'P'

      t.timestamps
    end
  end
end
