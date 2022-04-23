# frozen_string_literal: true

TicketBooth::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.default_url_options = { host: 'localhost:3000' }
  config.action_mailer.raise_delivery_errors = true

  # FIXME: Why?
  # pg_dump doesnt seem to work in the container in Kubernetes,
  # it works on docker-compose. Why do we need it?
  # https://stackoverflow.com/questions/41561883/pg-dump-error-while-running-rake-dbmigrate
  config.active_record.dump_schema_after_migration = false
end
