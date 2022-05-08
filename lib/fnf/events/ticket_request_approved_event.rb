# frozen_string_literal: true

require_relative 'abstract_event'

module FnF
  module Events
    # This event fires whenever the ticket request is approved
    class TicketRequestApprovedEvent < TicketRequestEvent
    end
  end
end
