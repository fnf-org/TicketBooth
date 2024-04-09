# frozen_string_literal: true

# Set environment to production unless something else is specified
app_name = 'tickets'
env = ENV['RAILS_ENV'] || 'production'
deploy_path = "#{Dir.home}/deploy"
shared_path = "#{deploy_path}/shared"

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen "/tmp/#{app_name}.socket", backlog: 64
listen 3000
pid    "#{shared_path}/pids/unicorn.#{app_name}.pid"

# Server has 4 cores
worker_processes 2

# Preload app for more speed
preload_app true

# Nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory "#{deploy_path}/current"

stderr_path "#{shared_path}/log/unicorn.#{app_name}.stderr.log"
stdout_path "#{shared_path}/log/unicorn.#{app_name}.stdout.log"

before_fork do |server, _worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{shared_path}/pids/unicorn.#{app_name}.pid.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # Process was already killed or no previous process exists
    end
  end
end

after_fork do |_server, _worker|
  # Required for Rails + "preload_app true",
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)

  # If preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.
end
