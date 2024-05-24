# frozen_string_literal: true

require 'ventable'
require_relative '../event_reporter'

module FnF
  module Events
    class AbstractEvent
      attr_accessor :target, :user

      def initialize(user: nil, target: nil)
        self.target = target
        self.user = user
      end

      class << self
        # @param [Object] subclass
        def inherited(subclass)
          # noinspection RubyMismatchedArgumentType
          super

          subclass.include Ventable::Event

          subclass.notifies(EventReporter)

          subclass.instance_eval do
            # For eg FnF::Events::TicketRequestEvent this should return :ticket_request
            # For eg FnF::Events::TicketRequestDeclinedEvent this should return :ticket_request_declined
            # For eg FnF::Events::TicketRequestApprovedEvent this should return :ticket_request_approved
            def ventable_callback_method_name
              ActiveSupport::Inflector.underscore(name)
                                      .gsub(%r{^fnf/events/}, '')
                                      .gsub(/_event$/, '')
                                      .to_sym
            end
          end
        end
      end
    end
  end
end
