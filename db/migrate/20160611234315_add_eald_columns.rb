# frozen_string_literal: true

class AddEaldColumns < ActiveRecord::Migration
  def change
    change_table :ticket_requests do |t|
      t.integer :early_arrival_passes, null: false, default: 0
      t.integer :late_departure_passes, null: false, default: 0
    end

    change_table :events do |t|
      t.column :early_arrival_price, :decimal, precision: 8, scale: 2, default: 0
      t.column :late_departure_price, :decimal, precision: 8, scale: 2, default: 0
    end

    create_table :eald_payments do |t|
      t.references :event
      t.string :stripe_charge_id, null: false
      t.integer :amount_charged_cents, null: false
      t.string :name, limit: 255, null: false
      t.string :email, limit: 255, null: false
      t.integer :early_arrival_passes, null: false, default: 0
      t.integer :late_departure_passes, null: false, default: 0
      t.timestamps
    end
  end
end
