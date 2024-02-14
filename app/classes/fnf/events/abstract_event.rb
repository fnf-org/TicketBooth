# frozen_string_literal: true

require 'ventable'

module FnF
  module Events
    class AbstractEvent
      attr_accessor :target, :user

      def initialize(user: nil, target: nil)
        self.target = target
        self.user = user
      end

      class << self
        # @param [Object] klass
        def inherited(klass)
          super(klass)
          klass.instance_eval do
            include Ventable::Event

            notifies ->(event) { EventReporter.metric(event, 1) }

            # For eg FnF::Events::TicketRequestEvent this should return :ticket_request
            def ventable_callback_method_name
              name.gsub(/^FnF::Events::/, '').underscore.downcase.to_sym
            end
          end
        end
      end
    end
  end
end
