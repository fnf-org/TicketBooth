# frozen_string_literal: true

require 'rails_helper'

module FnF
  RSpec.describe EventReporter do
    describe '#event_name' do
      before do
        expect(described_class).to receive(:metric).once
      end

      it 'invokes metric for all events' do
        Events.set_building_on_fire!
      end
    end
  end
end
