ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }
