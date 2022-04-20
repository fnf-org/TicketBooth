# frozen_string_literal: true

class AddRoleToTicketRequests < ActiveRecord::Migration
  def change
    change_table :ticket_requests do |t|
      t.string :role,             null: false, default: 'volunteer'
      t.string :role_explanation, null: true,  limit: 200
    end
  end
end
