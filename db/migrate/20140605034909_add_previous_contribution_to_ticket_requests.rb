# frozen_string_literal: true

class AddPreviousContributionToTicketRequests < ActiveRecord::Migration[6.0]
  def change
    change_table :ticket_requests do |t|
      t.string :previous_contribution, limit: 250, null: true
    end
  end
end
