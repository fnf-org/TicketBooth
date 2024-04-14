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

  TIME_FORMAT = '%Y/%m/%d %H:%M:%S'

  DATE_FORMATS.merge!({
                        friendly: '%A, %B %-d, %Y %l:%M %p %Z',
                        month_day: '%B %-d',
                        hmm: '%l:%M %p', # HMM = Hour minute meridian
                        dhmm: '%A, %l:%M %p' # DayOfWeek, HMM
                      })
end

class TimeHelper
  def self.from_picker(datetimepicker_string)
    ::DateTime.strptime(datetimepicker_string, Time::TIME_FORMAT).to_time if datetimepicker_string.present?
  end
end
