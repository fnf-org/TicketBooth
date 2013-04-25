class AddVolunteerShiftsToTicketRequests < ActiveRecord::Migration
  def change
    change_table :ticket_requests do |t|
      t.integer :volunteer_shifts
    end
  end
end
