# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'FnF'
  inflect.acronym 'CSV'
end

class Time
  unless method_defined?(:xmlschema)
    def xmlschema; end
  end
end
