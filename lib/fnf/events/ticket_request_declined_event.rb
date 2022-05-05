# frozen_string_literal: true

require_relative 'abstract_event'

module FnF
  module Events
    # This event fires whenever the ticket request is declined
    class TicketRequestDeclinedEvent < TicketRequestEvent
    end
  end
end
