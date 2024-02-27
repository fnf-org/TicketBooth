# frozen_string_literal: true

require 'newrelic_rpm'
require 'singleton'
module FnF
  class EventReporter
    class << self
      # Reports an error
      def error(exception, options)
        ::NewRelic::Agent.notice_error(exception, options)
      end

      # Increments a given metric
      def metric(event, value)
        ::NewRelic::Agent.record_metric(event_name(event), value)
      end

      protected

      def event_name(event)
        target_name = if event.target
                        event.target.respond_to?(:name) ? event.target.name : event.target.class.name
                      else
                        'unknown'
                      end
        name = "Custom/#{event.class.name.split('::').reject { |n| %w[FnF Events].include?(n) }.join('/')}"
        name = "#{name}/user-#{event.user.id}-#{event.user.email}" if event.user&.id && event.user&.email
        name = "#{name}/#{target_name.downcase}"
        name.gsub(/ */, '-')
      end
    end
  end
end
