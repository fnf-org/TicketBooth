# frozen_string_literal: true

require 'rails_helper'

# rubocop: disable RSpec/DescribeClass
RSpec.describe 'Rails.configuration.puma' do
  subject { Rails.configuration.puma }

  its(:min_threads) { is_expected.to be(1) }
  its(:max_threads) { is_expected.to be(1) }
  its(:workers) { is_expected.to be(1) }
  its(:port) { is_expected.to be(8080) }
end
# rubocop: enable RSpec/DescribeClass
