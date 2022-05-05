# frozen_string_literal: true

require_relative 'event_reporter'

module FnF
  module Events
  end
end

require_relative 'events/ticket_request_event'
require_relative 'events/ticket_request_approved_event'
