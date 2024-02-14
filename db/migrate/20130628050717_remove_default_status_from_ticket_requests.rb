# frozen_string_literal: true

class RemoveDefaultStatusFromTicketRequests < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      ALTER TABLE ticket_requests
          ALTER COLUMN status DROP DEFAULT
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE ticket_requests
          ALTER COLUMN status SET DEFAULT 'P'
    SQL
  end
end
