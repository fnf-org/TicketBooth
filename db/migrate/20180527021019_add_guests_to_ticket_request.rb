class AddGuestsToTicketRequest < ActiveRecord::Migration
  def change
    change_table :ticket_requests do |t|
      t.text :guests, null: true
    end
  end
end
