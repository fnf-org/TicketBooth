class ChangeCampingTypeOnTicketRequests < ActiveRecord::Migration
  def change
    remove_column :ticket_requests, :camping_type
    remove_column :ticket_requests, :camping_type_explanation

    change_table :ticket_requests do |t|
      t.boolean :car_camping, null: true
      t.string  :car_camping_explanation, limit: 200, null: true
    end
  end
end
