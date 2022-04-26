#!/usr/bin/env rake
# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

TicketBooth::Application.load_tasks

require 'timeout'

is_dev_test = %w[development test].include?(ENV.fetch('RAILS_ENV', 'development'))
if is_dev_test
  puts 'Loading dev/test tasks...'
  require 'rspec/core/rake_task'
  require 'rubocop/rake_task'
  require 'yard'

  RSpec::Core::RakeTask.new(:spec)
  RuboCop::RakeTask.new
end

namespace :todolist do
  task :statsetup do
    require 'rails/code_statistics'
    ::STATS_DIRECTORIES << %w[Uploaders app/uploaders]

    # For test folders not defined in CodeStatistics::TEST_TYPES (ie: spec/)
    ::STATS_DIRECTORIES << %w[Specs spec]
    CodeStatistics::TEST_TYPES << 'Specs'
  end
end

task stats: 'todolist:statsetup'
