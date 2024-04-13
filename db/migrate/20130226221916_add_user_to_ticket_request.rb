# frozen_string_literal: true

class AddUserToTicketRequest < ActiveRecord::Migration[6.0]
  def change
    change_table(:ticket_requests) do |t|
      t.column :user_id, :integer, null: false
      t.remove :name
      t.remove :email
    end
  end
end
