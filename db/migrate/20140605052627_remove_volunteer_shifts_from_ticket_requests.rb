# frozen_string_literal: true

class RemoveVolunteerShiftsFromTicketRequests < ActiveRecord::Migration
  def change
    remove_column :ticket_requests, :volunteer_shifts
  end
end
