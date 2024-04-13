# frozen_string_literal: true

require 'ventable'
require Rails.root.join('app/classes/fnf/events/abstract_event')
require Rails.root.join('app/classes/fnf/event_reporter')

module FnF
  module Events
    StructWithName = Struct.new(:name)

    TARGET = StructWithName.new('Statute of Liberty')
    USER = User.new(name: 'John Doe')

    class BuildingOnFireEvent < AbstractEvent; end

    class << self
      def set_building_on_fire
        BuildingOnFireEvent.new(user: USER, target: TARGET).fire!
      end
    end
  end
end
