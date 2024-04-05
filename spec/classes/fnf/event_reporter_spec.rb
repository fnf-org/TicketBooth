# frozen_string_literal: true

require 'rails_helper'

module FnF
  RSpec.describe EventReporter do
    # noinspection RailsParamDefResolve
    let(:handler_name) { ::FnF::Events::BuildingOnFireEvent.send(:ventable_callback_method_name) }

    before do
      described_class.instance_eval do
        def building_on_fire(event)
          metric(event, 1)
        end
      end
    end

    it 'is correct handler name' do
      expect(handler_name).to eq(:building_on_fire)
    end

    # rubocop: disable RSpec
    describe '#event_name' do
      before :suite do
        ::FnF::Events::BuildingOnFireEvent.configure { notifies EventReporter }
      end

      it 'invokes metric for all events' do
        expect(described_class).to receive(:metric).with(FnF::Events::BuildingOnFireEvent, 1).once

        Events.set_building_on_fire
      end
    end
    # rubocop: enable RSpec
  end
end
