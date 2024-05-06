# frozen_string_literal: true
# vim: ft=ruby

require 'etc'
require 'puma'
require 'puma/dsl'
require 'rails'
require_relative 'application'

silence_single_worker_warning
current_dir = File.expand_path('../', __dir__)
directory(current_dir) if Dir.exist?(current_dir)

@env = ENV['RAILS_ENV'] || 'development'
environment @env
require_relative "environments/#{@env}"

rackup "#{current_dir}/config.ru"
pidfile "#{current_dir}/tmp/pids/puma-#{@env}.pid"

puma_config = Rails.configuration.puma
port = puma_config.port
bind "tcp://0.0.0.0:#{port}"

threads puma_config.min_threads, puma_config.max_threads
workers puma_config.workers

tag 'ticket-booth'
preload_app!
worker_timeout 60
activate_control_app 'tcp://127.0.0.1:32123', { auth_token: 'fnf' }

DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S %z'

if ENV.fetch('NEWRELIC_ENABLED', false)
  require 'newrelic_rpm'

  lowlevel_error_handler do |exception|
    begin
      NewRelic::Agent.notice_error(exception)
    rescue StandardError
      nil
    end

    [500, {},
     [
       'An error has occurred, and engineers have been informed. ' \
       'Please reload the page. If you continue to have problems, ' \
       "contact fnf-support@googlegroups.com\n"
     ]]
  end
end
