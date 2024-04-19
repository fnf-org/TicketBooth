# frozen_string_literal: true

require 'rspec'
require 'tempfile'

require 'fnf/submission_links'

module FnF
  RSpec.describe SubmissionLinks do
    subject(:output_path) { output.path }

    let(:submission_links) { described_class.new(csv, output) }
    let(:pwd) { ::Dir.pwd }
    let(:csv) { "#{pwd}/spec/fixtures/chill_sets.csv" }
    let(:output) { ::Tempfile.new('output') }
    let(:expected) { ::File.read("#{pwd}/spec/fixtures/chill_sets.html") }

    before { submission_links.run }

    it { expect(File.exist?(output_path)).to be true }

    describe 'output contents' do
      subject { File.read(output.path) }

      it { is_expected.to eql(expected) }
    end
  end
end
