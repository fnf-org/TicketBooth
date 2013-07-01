class RemoveDefaultStatusFromTicketRequests < ActiveRecord::Migration
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
