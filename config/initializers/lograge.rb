# frozen_string_literal: true

require 'lograge'

# noinspection RubyResolve
Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.keep_original_rails_log = Rails.env.test?

  config.lograge.logger = ActiveSupport::Logger.new(Rails.env.test? ? nil : $stdout)

  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      user: controller.current_user.try(:name)
    }
  end
end
