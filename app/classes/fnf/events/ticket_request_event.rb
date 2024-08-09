# frozen_string_literal: true

require_relative 'abstract_event'

module FnF
  module Events
    # This event fires whenever the ticket request is submitted
    class TicketRequestEvent < AbstractEvent
      attr_accessor :ticket_request

      def initialize(user: nil, target: nil)
        super
        Rails.logger.info("TicketRequestEvent: target: #{target}")
        self.ticket_request = target
      end
    end
  end
end
