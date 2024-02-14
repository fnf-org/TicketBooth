# frozen_string_literal: true

class AddCampingTypeExplanationToTicketRequests < ActiveRecord::Migration[6.0]
  def change
    change_table :ticket_requests do |t|
      t.string :camping_type_explanation, limit: 200, null: true
    end
  end
end
