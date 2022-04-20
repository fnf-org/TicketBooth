#!/usr/bin/env rake
# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

TicketBooth::Application.load_tasks

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require 'timeout'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

task default: :spec
