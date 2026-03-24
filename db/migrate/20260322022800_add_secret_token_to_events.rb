# frozen_string_literal: true

class AddSecretTokenToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :secret_token, :string
    add_index :events, :secret_token, unique: true
  end
end
