# frozen_string_literal: true

module NumberToRoman
  NUMERAL_HASH = {
    1    => 'I',
    5    => 'V',
    10   => 'X',
    50   => 'L',
    100  => 'C',
    500  => 'D',
    1000 => 'M'
  }.to_a.reverse.to_h.freeze

  def to_roman(number_to_convert = self)
    StringIO.new.tap do |answer|
      NUMERAL_HASH.each do |num, numeral|
        if number_to_convert >= num
          num_numerals, number_to_convert = number_to_convert.divmod(num)
          num_numerals.times { answer.print(numeral) }
        end
      end
    end.string
  end
end

Numeric.include(NumberToRoman)
