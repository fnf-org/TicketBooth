# frozen_string_literal: true

require 'rspec'

RSpec.describe 'bin/music-submissions' do
  let(:pwd) { Dir.pwd }
  let(:script) { "#{pwd}/bin/music-submission-links" }
  let(:result) { Tempfile.new('result') }
  let(:expected) { File.read('spec/fixtures/chill_sets.html') }

  before do
    system("bash -c '#{script} #{pwd}/spec/fixtures/chill_sets.csv > #{result.path}'")
  end

  subject { File.read(result) }

  it { is_expected.to eq(expected) }
end
