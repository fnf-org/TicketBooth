# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

$stdout.sync = true
$stderr.sync = true

# Enable YJIT if we have it compiled in
if defined?(RubyVM::YJIT) && RubyVM::YJIT.respond_to?(:enable)
  RubyVM::YJIT.enable
  puts '[ ✔ ] YJIT is enabled'
else
  warn '[ 𐄂 ] YJIT is not enabled'
end

require 'simplecov'
SimpleCov.start 'rails'

require 'rspec'
require 'rspec/its'
require 'timeout'
require 'faker'

20.times { puts }; puts "\033[20A"

require_relative 'support/example_helper'

EXAMPLE_TIMEOUT = ENV.fetch('EXAMPLE_TIMEOUT', 20).to_i

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end

  # Adds timing printing and per-example timeout.
  ExampleHelper.new(config:, timeout: EXAMPLE_TIMEOUT, max_width: 40).wrap_example!
end

