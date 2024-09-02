# frozen_string_literal: true

class AddIndexToUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :authentication_token
  end
end
