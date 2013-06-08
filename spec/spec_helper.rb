ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl_helper'

module AttributeNormalizer::RSpecMatcher
  alias :normalize :normalize_attribute
end

RSpec.configure do |config|
  include AttributeNormalizer::RSpecMatcher
end
