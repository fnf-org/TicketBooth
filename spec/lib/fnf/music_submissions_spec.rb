# frozen_string_literal: true

require 'rspec'
require 'tempfile'

RSpec.describe 'music-submissions-links' do
  subject { File.read(result) }

  let(:pwd) { Dir.pwd }
  let(:script) { "#{pwd}/bin/music-submission-links" }
  let(:result) { Tempfile.new('result') }
  let(:expected) { File.read('spec/fixtures/chill_sets.html') }

  before do
    FileUtils.rm_f(result)

    system("bash -c '#{script} #{pwd}/spec/fixtures/chill_sets.csv > #{result.path}'")
  end

  it { is_expected.to eq(expected) }
end
