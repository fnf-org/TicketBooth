# frozen_string_literal: true

AttributeNormalizer.configure do |config|
  # Strip whitespace, squish consecutive whitespace, and nullify if blank string
  config.default_normalizers = :strip, :squish, :blank
end
