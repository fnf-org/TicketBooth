# frozen_string_literal: true

class AddAdminNotesToTicketRequests < ActiveRecord::Migration[6.0]
  def change
    change_table :ticket_requests do |t|
      t.string :admin_notes, limit: 512, null: true
    end
  end
end
