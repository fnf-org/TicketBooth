# frozen_string_literal: true

require 'ventable'
require 'fnf/events/abstract_event'

module FnF
  module Events
    StructWithName = Struct.new(:name)

    TARGET = StructWithName.new('Statute of Liberty')
    USER = User.new(name: 'Iynqvzve Mryrafxl')

    class BuildingOnFireEvent < AbstractEvent
    end

    class << self
      def set_building_on_fire!
        BuildingOnFireEvent.new(user: USER, target: TARGET).fire!
      end
    end
  end
end
