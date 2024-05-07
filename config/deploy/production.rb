# frozen_string_literal: true

set :ruby_version, File.read('.ruby-version')
set :node_version, '18'
set :yarn_version, File.read('.yarn-version')

set :target_os, 'linux'
set :rails_env, 'production'

require_relative '../../capistrano/loader/os'

server 'tickets.fnf.events', roles: %w[app db web], user: 'fnf', sudo: true
set :gem_config, {}
