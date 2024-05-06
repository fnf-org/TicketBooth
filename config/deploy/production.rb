# frozen_string_literal: true

set :ruby_version, '3.2.3'
set :node_version, '18'
set :yarn_version, `grep '"yarn"' package.json | awk '{print $2}' | sed 's/"//g'`

set :target_os, 'linux'
set :rails_env, 'production'

require_relative '../../capistrano/loader/os'

server 'tickets.fnf.events', roles: %w[app db web], user: 'fnf', sudo: true
set :gem_config, {}
