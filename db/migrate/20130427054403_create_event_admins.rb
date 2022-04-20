# frozen_string_literal: true

class CreateEventAdmins < ActiveRecord::Migration
  def change
    create_table :event_admins do |t|
      t.references :event
      t.references :user

      t.timestamps
    end

    add_index :event_admins, %i[event_id user_id], unique: true
    add_index :event_admins, :user_id
  end
end
