# frozen_string_literal: true

class AddStripeRefundIdToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :stripe_refund_id, :string
  end
end
