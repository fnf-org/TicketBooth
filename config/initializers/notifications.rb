# frozen_string_literal: true

ActiveSupport::Notifications.subscribe 'redirect_to.action_controller' do |event|
  Rails.logger.warn "NOTIFICATIONS: redirect -> [#{event.payload[:location]}] , status: [#{event.payload[:status]}]".colorize(:yellow)
  Rails.logger.warn "NOTIFICATIONS: event:   -> [#{event.inspect}".colorize(:magenta)
end
