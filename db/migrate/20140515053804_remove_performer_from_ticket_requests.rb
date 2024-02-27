# frozen_string_literal: true

class RemovePerformerFromTicketRequests < ActiveRecord::Migration[6.0]
  def change
    remove_column :ticket_requests, :performer
  end
end
