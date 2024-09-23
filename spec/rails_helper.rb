# frozen_string_literal: true

require_relative 'spec_helper'

ENV['RAILS_ENV'] = 'test'

require File.expand_path('../config/environment', __dir__)

require 'rspec/rails'
require 'accept_values_for'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before :example, :ventable_disabled do
    Ventable.disable
  end

  config.after :example, :ventable_disabled do
    Ventable.enable
  end

  config.use_transactional_fixtures = true

  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
