# frozen_string_literal: true

require 'colorize'

set :application, 'tickets'
set :repo_url, 'git@github.com:fnf-org/TicketBooth.git'

set :bundle_flags, '--jobs=8 --deployment'
set :bundle_without, 'development test'
set :bundle_env_variables, { nokogiri_use_system_libraries: 1 }
set :branch, 'main'
set :remote_user, 'fnf'
set :user_home, '/home/fnf'
set :deploy_to, "#{fetch(:user_home)}/apps/tickets"

# Default value for :format is :pretty
set :format, :airbrussh
set :log_level, :info
set :pty, true

set :rbenv, "#{fetch(:user_home)}/.rbenv/bin/rbenv"
set :native_gems, %i[nokogiri]
set :ruby_bin_dir, "#{fetch(:user_home)}/.rbenv/shims"

set :ssh_options, {
  keys:          %W[
    #{ENV.fetch('HOME', '~')}/.ssh/id_rsa
    #{ENV.fetch('HOME', '~')}/.ssh/id_dsa
  ],
  forward_agent: false,
  auth_methods:  %w[publickey]
}

set :assets_manifests, -> {
  [release_path.join("public", fetch(:assets_prefix), '.manifest.json')]
}

set :linked_files, %w[config/master.key]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system]
set :default_env, {}

# Default value for keep_releases is 5
set :keep_releases, 5

before 'bundler:install', 'ruby:bundler:native_config'

namespace :deploy do
  before :starting, 'deploy:setup'
  namespace(:assets) { after :precompile, 'deploy:permissions' }

  before :publishing, 'ruby:bundler:bundle'

  before 'deploy:assets:precompile', 'deploy:migrate'
  before 'deploy:assets:precompile', 'node:install'
  before 'deploy:assets:precompile', 'node:yarn:install'

  before :publishing, 'puma:stop'
  after :publishing, 'puma:start'
end
