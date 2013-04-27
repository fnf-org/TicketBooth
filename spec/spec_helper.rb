ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec'
require 'rails/test_help'
require 'factory_girl_helper'

module AttributeNormalizer::RSpecMatcher
  alias :normalize :normalize_attribute
end

RSpec.configure do |config|
  config.color_enabled = true # Use color in STDOUT

  include AttributeNormalizer::RSpecMatcher
end
