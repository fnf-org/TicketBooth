# frozen_string_literal: true

class AddSpecialPriceToTicketRequests < ActiveRecord::Migration[6.0]
  def change
    change_table(:ticket_requests) do |t|
      t.column :special_price, :decimal, precision: 8, scale: 2, null: true
    end
  end
end
