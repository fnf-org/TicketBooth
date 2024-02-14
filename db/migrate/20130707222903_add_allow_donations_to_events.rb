# frozen_string_literal: true

class AddAllowDonationsToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :allow_donations, :boolean, default: false, null: false
  end
end
