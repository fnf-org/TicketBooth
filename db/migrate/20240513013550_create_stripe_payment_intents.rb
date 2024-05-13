# frozen_string_literal: true

class CreateStripePaymentIntents < ActiveRecord::Migration[7.1]
  def change
    create_table :stripe_payment_intents do |t|
      t.string :intent_id, null: false
      t.string :status, null: false
      t.integer :amount, null: false
      t.string :description
      t.string :customer_id
      t.string :last_payment_error

      t.references(:payment, foreign_key: true, type: :integer)

      t.timestamps

      t.index(:intent_id)
    end
  end
end
