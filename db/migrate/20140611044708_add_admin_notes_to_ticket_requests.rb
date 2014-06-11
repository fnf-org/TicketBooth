class AddAdminNotesToTicketRequests < ActiveRecord::Migration
  def change
    change_table :ticket_requests do |t|
      t.string :admin_notes, limit: 512, null: true
    end
  end
end
