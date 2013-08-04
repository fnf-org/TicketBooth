# Add an alias for testing attribute normalizations defined with the
# `normalize_attributes` DSL provided by the attribute_normalizer gem.
module AttributeNormalizer::RSpecMatcher
  alias :normalize :normalize_attribute
end

RSpec.configure do |config|
  include AttributeNormalizer::RSpecMatcher
end
