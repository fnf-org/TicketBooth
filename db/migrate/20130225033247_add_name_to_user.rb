# frozen_string_literal: true

class AddNameToUser < ActiveRecord::Migration[6.0]
  def change
    change_table(:users) do |t|
      t.column :name, :string, limit: 70, null: false
    end
  end
end
