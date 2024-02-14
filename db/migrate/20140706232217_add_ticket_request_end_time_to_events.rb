# frozen_string_literal: true

class AddTicketRequestEndTimeToEvents < ActiveRecord::Migration[6.0]
  def change
    change_table :events do |t|
      t.datetime :ticket_requests_end_time, null: true
    end
  end
end
