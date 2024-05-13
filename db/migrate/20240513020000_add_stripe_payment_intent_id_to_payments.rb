# frozen_string_literal: true

class AddStripePaymentIntentIdToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :stripe_payment_intent_id, :integer
    add_index :payments, :stripe_payment_intent_id, where: 'stripe_payment_intent_id is not NULL'

    add_foreign_key :payments, :stripe_payment_intents, on_delete: :restrict

    change_column_default :payments, :status, from: 'P', to: 'N'
  end
end
