class AddVehicleCampingRequestedToTicketRequests < ActiveRecord::Migration
  def change
    add_column :ticket_requests, :vehicle_camping_requested, :boolean
  end
end
