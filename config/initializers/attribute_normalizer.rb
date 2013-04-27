AttributeNormalizer.configure do |config|
  # Strip whitespace, squish consecutive whitespace, and nilify if blank string
  config.default_normalizers = :strip, :squish, :blank
end
