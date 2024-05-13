# frozen_string_literal: true

class AddStripePaymentIdToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :stripe_payment_id, :string
    add_index :payments, :stripe_payment_id
    change_column_default :payments, :status, from: 'P', to: 'N'
  end
end
