# frozen_string_literal: true

# Enable YJIT if we have it compiled in
if defined?(RubyVM::YJIT) && RubyVM::YJIT.respond_to?(:enable)
  RubyVM::YJIT.enable
  puts '[ ✔ ] YJIT is enabled'
else
  warn '[ 𐄂 ] YJIT is not enabled'
end

ENV['RAILS_ENV'] = 'test'

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
end
