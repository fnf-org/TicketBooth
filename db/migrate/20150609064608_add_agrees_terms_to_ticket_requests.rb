# frozen_string_literal: true

class AddAgreesTermsToTicketRequests < ActiveRecord::Migration
  def change
    add_column :ticket_requests, :agrees_to_terms, :boolean
  end
end
