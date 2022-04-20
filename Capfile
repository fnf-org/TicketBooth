# frozen_string_literal: true

# Ensure we run within a Bundler context with the correct version of Capistrano
exec('bundle', 'exec', $PROGRAM_NAME, *ARGV) unless defined?(Bundler)

load 'deploy'
load 'deploy/assets'
load 'config/deploy' # remove this line to skip loading any of the default tasks
