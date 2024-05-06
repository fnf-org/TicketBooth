# frozen_string_literal: true

set :ruby_version, '3.2.3'
set :target_os, 'linux'
set :rails_env, 'production'

require_relative '../../lib/capistrano/loader/os'

server 'tickets.fnf.events', roles: %w[app db web], user: 'fnf', sudo: false
set :gem_config, {}
