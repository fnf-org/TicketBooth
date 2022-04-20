# frozen_string_literal: true

class AddPerformerToTicketRequest < ActiveRecord::Migration
  def change
    change_table :ticket_requests do |t|
      t.boolean :performer, null: false, default: false
    end
  end
end
