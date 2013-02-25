class AddNameToUser < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.column :name, :string, limit: 70, null: false
    end
  end
end
