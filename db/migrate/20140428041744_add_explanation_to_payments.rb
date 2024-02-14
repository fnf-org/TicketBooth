# frozen_string_literal: true

class AddExplanationToPayments < ActiveRecord::Migration[6.0]
  def change
    change_table :payments do |t|
      t.string :explanation, null: true
    end
  end
end
