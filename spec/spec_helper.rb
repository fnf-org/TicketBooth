# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

# Enable YJIT if we have it compiled in
if defined?(RubyVM::YJIT) && RubyVM::YJIT.respond_to?(:enable)
  RubyVM::YJIT.enabled? ? warn('[ 𐄂 ] YJIT is enabled') : warn('[ 𐄂 ] YJIT is disabled')
  # uncomment when we determine if the spec failures are due to YJIT
  # RubyVM::YJIT.enable
  # puts '[ ✔ ] YJIT is enabled'
else
  warn '[ 𐄂 ] YJIT is not enabled'
end

require 'simplecov'
SimpleCov.start 'rails'

require 'rspec'
require 'rspec/its'
require 'timeout'
require 'faker'

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end

  config.around do |example|
    Timeout.timeout(5) do
      example.run
    end
  end
end
