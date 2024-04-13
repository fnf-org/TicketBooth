# frozen_string_literal: true

class RenameAssistanceToNeedsAssistance < ActiveRecord::Migration[6.0]
  def change
    change_table :ticket_requests do |t|
      t.rename :assistance, :needs_assistance
    end
  end
end
