class AddDonationToTicketRequests < ActiveRecord::Migration
  def change
    add_column :ticket_requests, :donation, :decimal, precision: 8, scale: 2, default: 0
  end
end
