# frozen_string_literal: true

class AddStartAndEndTicketSaleTimesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :ticket_sales_start_time, :datetime
    add_column :events, :ticket_sales_end_time, :datetime
  end
end
