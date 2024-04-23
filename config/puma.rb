# vim: ft=ruby
# frozen_string_literal: true

require 'English'
require 'etc'

silence_single_worker_warning
current_dir = File.expand_path('../', __dir__)
directory(current_dir) if Dir.exist?(current_dir)

@env = ENV['RAILS_ENV'] || 'development'
environment @env
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

# log_requests
# log_formatter do |str|
#   "#{format '%5d', $PROCESS_ID} | #{Time.zone.now.strftime DATETIME_FORMAT} : |puma| #{str}"
# end

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
