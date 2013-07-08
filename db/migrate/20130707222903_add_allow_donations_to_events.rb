class AddAllowDonationsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :allow_donations, :boolean, default: false, null: false
  end
end
