# frozen_string_literal: true

require 'ventable'
require_relative 'events/ticket_request_event'
require_relative 'events/ticket_request_approved_event'
require_relative 'events/ticket_request_declined_event'

require_relative '../../mailers/ticket_request_mailer'

module FnF
  module Events
    class << self
      attr_accessor :initialized

      def initialize_events!
        return if initialized

        TicketRequestEvent.configure { notifies ::TicketRequestMailer }

        TicketRequestDeclinedEvent.configure { notifies ::TicketRequestMailer }

        TicketRequestApprovedEvent.configure { notifies ::TicketRequestMailer }

        self.initialized = true
      end
    end
  end
end

FnF::Events.initialize_events!
