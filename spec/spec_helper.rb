# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start 'rails'
  puts 'required simplecov'
end
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with(:rspec) do |c|
    c.syntax = %i[should expect]
  end
end
