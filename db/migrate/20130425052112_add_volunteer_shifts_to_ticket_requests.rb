# frozen_string_literal: true

class AddVolunteerShiftsToTicketRequests < ActiveRecord::Migration[6.0]
  def change
    change_table :ticket_requests do |t|
      t.integer :volunteer_shifts
    end
  end
end
