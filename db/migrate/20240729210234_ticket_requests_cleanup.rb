# frozen_string_literal: true

class TicketRequestsCleanup < ActiveRecord::Migration[7.1]
  def change
    remove_column :ticket_requests, :cabins
    remove_column :ticket_requests, :car_camping
    remove_column :ticket_requests, :car_camping_explanation
    remove_column :ticket_requests, :early_arrival_passes
    remove_column :ticket_requests, :late_departure_passes
  end
end
