# frozen_string_literal: true

class AddRequireRoleToEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :require_role, :boolean, default: true, null: false
  end
end
