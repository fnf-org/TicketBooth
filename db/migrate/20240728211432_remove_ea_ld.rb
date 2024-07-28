# frozen_string_literal: true

class RemoveEaLd < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :events do |t|
        direction.up   { t.change :early_arrival_price, :decimal }
        direction.down { t.remove :early_arrival_price }

        direction.up   { t.change :late_departure_price, :decimal }
        direction.down { t.remove :late_departure_price }

        direction.up   { t.change :cabin_price, :decimal }
        direction.down { t.remove :cabin_price }

        direction.up   { t.change :max_cabin_requests, :integer }
        direction.down { t.remove :max_cabin_requests }

        direction.up   { t.change :max_cabins_per_request, :integer }
        direction.down { t.remove :max_cabins_per_request }
      end
    end

    drop_table :eald_payments
  end
end
