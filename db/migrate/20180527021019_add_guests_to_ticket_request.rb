# frozen_string_literal: true

class AddGuestsToTicketRequest < ActiveRecord::Migration[6.0]
  def change
    change_table :ticket_requests do |t|
      t.text :guests, null: true
    end
  end
end
