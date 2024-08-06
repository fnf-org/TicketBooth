class PaymentProvider < ActiveRecord::Migration[7.1]

  def change
    create_enum :payment_provider, ["stripe", "cash", "other"]
    create_enum :payment_status, ["new", "in_progress", "received", "refunded"]
    rename_column :payments, :status, :old_status

    add_column :payments, :provider, :enum, enum_type: :payment_provider, default: "stripe", null: false
    add_column :payments, :status, :enum, enum_type: :payment_status, default: "new", null: false
  end
end
