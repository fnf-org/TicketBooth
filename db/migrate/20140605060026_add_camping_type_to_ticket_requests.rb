# frozen_string_literal: true

class AddCampingTypeToTicketRequests < ActiveRecord::Migration[6.0]
  def change
    remove_column :ticket_requests, :vehicle_camping_requested

    change_table :ticket_requests do |t|
      t.string :camping_type, limit: 10
    end
  end
end
