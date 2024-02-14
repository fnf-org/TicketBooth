# frozen_string_literal: true

class AddRequireMailingAddressToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :require_mailing_address, :boolean, default: false, null: false
  end
end
