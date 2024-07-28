# frozen_string_literal: true

class EventPricesAsIntegers < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :events do |t|
        direction.up   { t.change :adult_ticket_price, :decimal, precision: 2 }
        direction.down { t.change :adult_ticket_price, :integer }

        direction.up   { t.change :kid_ticket_price, :decimal, precision: 2 }
        direction.down { t.change :kid_ticket_price, :integer }
      end
    end
  end
end
