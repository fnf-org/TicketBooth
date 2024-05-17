# frozen_string_literal: true

class AddDeletedAtToTicketRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :ticket_requests, :deleted_at, :datetime
    add_index :ticket_requests, :deleted_at, where: 'deleted_at is NULL'
  end
end
