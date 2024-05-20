class AddGuestKidsToTicketRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :ticket_requests, :guests_kids, :text
  end
end
