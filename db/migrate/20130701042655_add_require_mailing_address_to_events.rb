class AddRequireMailingAddressToEvents < ActiveRecord::Migration
  def change
    add_column :events, :require_mailing_address, :boolean, default: false, null: false
  end
end
