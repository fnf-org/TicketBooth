# frozen_string_literal: true

require 'etc'

current_dir = File.expand_path('../')
directory(current_dir) if Dir.exist?(current_dir)

@env = ENV['RAILS_ENV'] || 'development'

if @env == 'development'
  bind 'tcp://127.0.0.1:3000'
  threads 1, 5
  workers 1
else
  bind 'tcp://0.0.0.0:3000'
  threads 4, 16
end

tag 'ticket-booth'

preload_app!

worker_timeout 60
activate_control_app 'tcp://127.0.0.1:32123', { auth_token: 'fnf' }
