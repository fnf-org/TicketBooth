
# frozen_string_literal: true

require 'spec_helper'
require 'fnf/csv_reader'

module FnF
  class Counter
    attr_reader :counter

    def initialize
      @counter = 0
    end

    def increment!
      @counter += 1
    end
  end

  RSpec.describe CSVReader do
    let(:path) { 'spec/fixtures/chill_sets.csv' }
    let(:counter) { Counter.new }
    let(:block) { -> { counter.increment! } }

    subject { described_class.new(path) }

    it 'should yield each line of the CSV' do
      subject.read { block[] }
      expect(counter.counter).to eq(19)
    end
  end
end
