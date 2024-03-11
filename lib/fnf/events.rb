# frozen_string_literal: true

require_relative '../../app/classes/fnf/event_reporter'

module FnF
  module Events
  end
end

require_relative 'events/pp/classes/fnf/ticket_request_event'
require_relative 'events/pp/classes/fnf/ticket_request_approved_event'
