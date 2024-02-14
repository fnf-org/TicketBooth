# frozen_string_literal: true

class RemoveNotNullConstraintFromTicketRequestAddress < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      ALTER TABLE ticket_requests
        ALTER COLUMN address DROP NOT NULL
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE ticket_requests
        ALTER COLUMN address SET NOT NULL
    SQL
  end
end
