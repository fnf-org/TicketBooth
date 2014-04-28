class AddExplanationToPayments < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.string :explanation, null: true
    end
  end
end
