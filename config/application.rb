# frozen_string_literal: true

require_relative 'boot'

require 'time'
require 'etc'
require 'hashie/mash'

class Time
  # Ruby 1.9 has Date#xmlschema which converts to a string without the time component.
  # Moved the following line out of class Date.
  unless method_defined?(:xmlschema)
    def xmlschema; end
  end
end

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TicketBooth
  class Application < Rails::Application
    # Application Version
    VERSION  = File.read('.version').freeze

    # Read the latest revision
    REVISION = if File.exist?('REVISION')
                 File.read('REVISION').strip
               elsif Dir.exist?('.git')
                 `git rev-parse --short HEAD`.strip
               else
                 VERSION
               end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Pacific Time (US & Canada)'
    config.eager_load_paths << Rails.root.join('app/classes')

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Puma Configuration
    config.puma = Hashie::Mash.new(config_for(:puma))

    # default host for the routes
    routes.default_url_options[:host] = config.puma.host

    config.active_job.queue_adapter = ActiveJob::QueueAdapters::AsyncAdapter.new \
      min_threads: 1,
      max_threads: 3,
      idletime:    30.seconds

    config.cache_store = :mem_cache_store, '127.0.0.1:11211', { pool: { size: 10 } }

    config.action_mailer.preview_paths << "#{Rails.root}/lib/mailer_previews"
  end
end
