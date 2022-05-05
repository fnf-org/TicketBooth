# frozen_string_literal: true

require 'ventable'
require_relative '../../lib/fnf/events'

module FnF
  module Events
    TicketRequestEvent.configure do
      notifies ::TicketRequestMailer
    end

    TicketRequestApprovedEvent.configure do
      notifies ::TicketRequestMailer
    end

  end
end
