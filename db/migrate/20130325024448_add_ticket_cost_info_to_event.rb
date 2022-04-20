# frozen_string_literal: true

class AddTicketCostInfoToEvent < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.column :adult_ticket_price, :decimal, precision: 8, scale: 2
      t.column :kid_ticket_price, :decimal, precision: 8, scale: 2
      t.column :cabin_price, :decimal, precision: 8, scale: 2
      t.column :max_adult_tickets_per_request, :integer
      t.column :max_kid_tickets_per_request, :integer
      t.column :max_cabins_per_request, :integer
    end
  end
end
