# frozen_string_literal: true

require 'rspec'
require 'tempfile'

RSpec.describe 'bin/music-submissions' do
  subject { File.read(result) }

  let(:pwd) { Dir.pwd }
  let(:script) { "#{pwd}/bin/music-submission-links" }
  let(:result) { Tempfile.new('result') }
  let(:expected) { File.read('spec/fixtures/chill_sets.html') }

  before do
    system("bash -c '#{script} #{pwd}/spec/fixtures/chill_sets.csv > #{result.path}'")
  end

  it { is_expected.to eq(expected) }
end
