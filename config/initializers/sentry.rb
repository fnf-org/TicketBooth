# frozen_string_literal: true

require 'raven'

if Rails.env.production?
  raven_config = YAML.load_file("#{Rails.root}/config/sentry.yml")

  Raven.configure do |config|
    config.ssl_verification = false
    config.environments = %w[production]
    config.dsn = raven_config['dsn']
  end
end
