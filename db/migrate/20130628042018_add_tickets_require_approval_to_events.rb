# frozen_string_literal: true

class AddTicketsRequireApprovalToEvents < ActiveRecord::Migration
  def change
    add_column :events, :tickets_require_approval, :boolean, default: true, null: false
  end
end
