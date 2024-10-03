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

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end

  config.around do |example|
    # 10 seconds should be more than enough for ANY spec
    Timeout.timeout(ENV.fetch('RSPEC_TIMEOUT', 30).to_i) do
      example.run
    end
  end
end
