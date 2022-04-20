# frozen_string_literal: true

class AddEventIdToTicketRequest < ActiveRecord::Migration
  def change
    add_column :ticket_requests, :event_id, :integer, null: false
  end
end
