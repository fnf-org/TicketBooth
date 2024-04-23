# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Numeric do
  shared_examples 'roman literals' do |number, roman_literal|
    subject { number.to_roman }

    it { is_expected.to be_a(String) }
    it("#{roman_literal} ➜ #{number}") { is_expected.to eql(roman_literal) }
  end

  describe '.to_roman' do
    it_behaves_like 'roman literals', 1, 'I'
    it_behaves_like 'roman literals', 5, 'V'
    it_behaves_like 'roman literals', 6, 'VI'
    it_behaves_like 'roman literals', 9, 'VIIII'
    it_behaves_like 'roman literals', 11, 'XI'
    it_behaves_like 'roman literals', 20, 'XX'
    it_behaves_like 'roman literals', 21, 'XXI'
  end
end
