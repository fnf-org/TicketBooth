class AddStripePaymentIdToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :stripe_payment_id, :string
    add_index :payments, :stripe_payment_id
  end
end
