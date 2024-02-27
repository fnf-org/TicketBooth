# frozen_string_literal: true

class Worker
  @events = {}

  class << self
    attr_accessor :events

    def register(event)
      events[event.class.name] ||= 0
      events[event.class.name] += 1
    end

    def building_on_fire_event(event)
      register(event)
    end
  end
end

# using FnF::Events::BuildingOnFireEvent @see spec/support/events.rb
RSpec.describe 'Observers' do
  subject { worker.events }

  let(:worker) { Worker }
  let(:event) { FnF::Events::BuildingOnFireEvent }

  before do
    event.configure { notifies Worker }

    FnF::Events.set_building_on_fire!
  end

  it { is_expected.not_to be_empty }
end
