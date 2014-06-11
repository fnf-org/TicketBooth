class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :authentication_token, limit: 64, null: true
    end
  end
end
