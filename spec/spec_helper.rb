# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

$stdout.sync = true
$stderr.sync = true

# Enable YJIT if we have it compiled in
if defined?(RubyVM::YJIT) && RubyVM::YJIT.respond_to?(:enable)
  RubyVM::YJIT.enable
  warn '[ ✔ ] YJIT is enabled'
else
  warn '[ 𐄂 ] YJIT is not enabled'
end

require 'simplecov'
SimpleCov.start 'rails'

require 'rspec'
require 'rspec/its'
require 'timeout'
require 'faker'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<STRIPE_API_KEY>') { Rails.configuration.stripe[:secret_api_key] }
end

EXAMPLE_TIMEOUT = ENV.fetch('EXAMPLE_TIMEOUT', 20).to_i

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end
end
