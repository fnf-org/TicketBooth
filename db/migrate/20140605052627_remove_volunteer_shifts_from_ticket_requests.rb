# frozen_string_literal: true

class RemoveVolunteerShiftsFromTicketRequests < ActiveRecord::Migration[6.0]
  def change
    remove_column :ticket_requests, :volunteer_shifts
  end
end
