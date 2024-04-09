# frozen_string_literal: true

class CreateSiteAdmins < ActiveRecord::Migration[6.0]
  def change
    create_table :site_admins do |t|
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
