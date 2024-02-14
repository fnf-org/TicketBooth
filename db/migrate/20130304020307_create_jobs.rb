# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs do |t|
      t.belongs_to :event, null: false
      t.string :name, limit: 100, null: false
      t.string :description, limit: 512, null: false

      t.timestamps
    end
  end
end
