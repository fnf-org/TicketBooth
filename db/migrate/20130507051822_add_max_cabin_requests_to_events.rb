# frozen_string_literal: true

class AddMaxCabinRequestsToEvents < ActiveRecord::Migration[6.0]
  def change
    change_table :events do |t|
      t.integer :max_cabin_requests
    end
  end
end
