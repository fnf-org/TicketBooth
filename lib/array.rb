# frozen_string_literal: true

unless Array.new.respond_to?(:avg)
  class Array
    def avg
      if all?(Numeric) && size > 0
        sum.to_f / size.to_f
      else
        raise ArgumentError, 'Array must contain only numbers, and have size greater than 0, got ' + inspect
      end
    end
  end
end
