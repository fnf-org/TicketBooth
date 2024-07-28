class EventPricesAsIntegers < ActiveRecord::Migration[7.1]
  def change
    change_column :events, :adult_ticket_price, :integer
    change_column :events, :kid_ticket_price, :integer
  end
end
