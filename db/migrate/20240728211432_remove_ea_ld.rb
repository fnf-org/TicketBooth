class RemoveEaLd < ActiveRecord::Migration[7.1]
  def change
    remove_column :events, :early_arrival_price
    remove_column :events, :late_departure_price
    remove_column :events, :cabin_price
    remove_column :events, :max_cabin_requests
    remove_column :events, :max_cabins_per_request

    drop_table :eald_payments

  end
end
