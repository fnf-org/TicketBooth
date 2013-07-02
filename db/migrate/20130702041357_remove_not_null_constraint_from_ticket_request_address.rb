class RemoveNotNullConstraintFromTicketRequestAddress < ActiveRecord::Migration
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
