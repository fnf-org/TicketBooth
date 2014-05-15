class RemovePerformerFromTicketRequests < ActiveRecord::Migration
  def change
    remove_column :ticket_requests, :performer
  end
end
