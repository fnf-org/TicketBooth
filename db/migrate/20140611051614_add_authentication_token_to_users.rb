# frozen_string_literal: true

class AddAuthenticationTokenToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :authentication_token, limit: 64, null: true
    end
  end
end
