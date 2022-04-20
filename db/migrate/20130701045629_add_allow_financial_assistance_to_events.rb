# frozen_string_literal: true

class AddAllowFinancialAssistanceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :allow_financial_assistance, :boolean, default: false, null: false
  end
end
