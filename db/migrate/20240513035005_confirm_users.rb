class ConfirmUsers < ActiveRecord::Migration[7.1]
  def up
    execute 'update users set confirmed_at = now() where confirmed_at is null and sign_in_count is not null and sign_in_count > 0'
  end
  
  def down
    raise IrreversibleMigration
  end
end
