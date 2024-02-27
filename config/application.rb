# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'twitter-bootstrap-rails'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TicketBooth
  class Application < ::Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.time_zone = 'Pacific Time (US & Canada)'

    config.generators.test_framework = :rspec

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Force application to not access DB or load models when precompiling assets
    config.assets.initialize_on_precompile = false

    config.eager_load_paths << Rails.root.join('app/classes')
  end
end

require_relative '../app/classes/fnf/events'
