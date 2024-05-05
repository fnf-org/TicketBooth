# frozen_string_literal: true

require 'lograge'

# noinspection RubyResolve
Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.keep_original_rails_log = Rails.env.test?
  config.lograge.logger = ActiveSupport::Logger.new(Rails.env.test? ? nil : $stdout)
  config.lograge.custom_options = lambda do |event|
    request = event.payload[:request]
    stacktrace = Rails.backtrace_cleaner.clean(event.payload[:exception_object].backtrace) if event.payload[:exception_object]

    {
      params:     request.filtered_parameters.except(:controller, :action),
      request_id: request.request_id,
      exception:  event.payload[:exception],
      stacktrace:
    }
  end
  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      user: controller.current_user.try(:name)
    }
  end
end
