# frozen_string_literal: true

require_relative 'spec_helper'

ENV['RAILS_ENV'] = 'test'

require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'accept_values_for'
require 'stripe_mock'
require 'timeout'

def example_with_timeout(example)
  Timeout.timeout(20) { example.run }
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before do
    @stripe_test_helper = StripeMock.create_test_helper
    StripeMock.start
  end

  config.after { StripeMock.stop }

  config.before :example, :ventable_disabled do
    Ventable.disable
  end

  config.after :example, :ventable_disabled do
    Ventable.enable
  end

  config.around { |example| example_with_timeout(example) }

  config.use_transactional_fixtures = true

  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
