# frozen_string_literal: true

require 'etc'

bind 'tcp://127.0.0.1:3000'
current_dir = File.expand_path('../')
directory(current_dir) if Dir.exist?(current_dir)

workers [[Etc.nprocessors, 2].max, 12].min

@env = ENV['RAILS_ENV'] || 'development'

if @env == 'development'
  threads 1, 5
  workers 1
else
  threads 4, 16
  workers Etc.nprocessors
end

tag 'ticket-booth'

preload_app!
worker_timeout 75
activate_control_app 'tcp://127.0.0.1:32123', { auth_token: 'fnf' }
