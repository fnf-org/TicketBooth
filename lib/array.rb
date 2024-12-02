# frozen_string_literal: true

unless [].respond_to?(:avg)
  class Array
    def avg
      raise ArgumentError, "Array must contain only numbers, and have size greater than 0, got #{inspect}" unless all?(Numeric) && size > 0

      sum / size.to_f
    end
  end
end
