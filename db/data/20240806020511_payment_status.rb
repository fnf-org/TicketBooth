# frozen_string_literal: true

class PaymentStatus < ActiveRecord::Migration[7.1]
  def up
    matrix = {'N' => 'new', 'P' => 'in progress', 'R' => 'received', 'F' => 'refunded'}
    Payment.find_each do |p|
      p.status = matrix[p.old_status]
      p.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
