class CreateTicketRequestsEventsAddons < ActiveRecord::Migration[7.1]
  def change
    create_table :ticket_requests_events_addons do |t|
      t.references :ticket_requests, index: true, foreign_key: true, null: false
      t.references :events_addons, index: true, foreign_key: true, null: false
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
