# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'simplecov'
require 'codecov' if ENV['CODECOV_TOKEN']
SimpleCov.start 'rails'

require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'accept_values_for'
require 'stripe_mock'
require 'timeout'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

def example_with_timeout(example)
  Timeout.timeout(20) { example.run }
end

TicketBooth::Application.configure do
  config.action_mailer.delivery_method = :test
end

RSpec.configure do |config|
  config.before(:each) do
    @stripe_test_helper = StripeMock.create_test_helper
    StripeMock.start
  end

  config.after(:each) { StripeMock.stop }

  config.around(:each) { |example| example_with_timeout(example) }

  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end
end
