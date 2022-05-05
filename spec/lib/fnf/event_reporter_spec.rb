# frozen_string_literal: true

require 'spec_helper'
require 'fnf/csv_reader'

module FnF
  RSpec.describe EventReporter do
    describe '#event_name' do

      before do
        expect(EventReporter).to receive(:metric).once
      end

      it 'should invoke metric for all events' do
        Events.set_building_on_fire!
      end
    end
  end
end
