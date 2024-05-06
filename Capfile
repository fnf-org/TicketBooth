# frozen_string_literal: true

# Load DSL and Setup Up Stages
require 'airbrussh/capistrano'
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'
require 'capistrano/console'

require 'capistrano/bundler'
require 'capistrano/rails/assets'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Loads custom tasks from capistrano/tasks if you have any defined.
Dir.glob('capistrano/tasks/**.cap').each { |r| import r }
