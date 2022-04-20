# frozen_string_literal: true

# Add an alias for testing attribute normalizations defined with the
# `normalize_attributes` DSL provided by the attribute_normalizer gem.
module AttributeNormalizer
  module RSpecMatcher
    alias normalize normalize_attribute
  end
end

RSpec.configure do |_config|
  include AttributeNormalizer::RSpecMatcher
end
