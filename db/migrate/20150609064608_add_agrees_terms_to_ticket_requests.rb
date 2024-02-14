# frozen_string_literal: true

class AddAgreesTermsToTicketRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :ticket_requests, :agrees_to_terms, :boolean
  end
end
