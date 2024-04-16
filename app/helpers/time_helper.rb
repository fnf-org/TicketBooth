# frozen_string_literal: true

require 'date'
require 'active_support/core_ext/date_and_time/compatibility'

module TimeHelper
  TIME_FORMAT = '%m/%d/%Y, %H:%M %p %Z'

  class << self
    def to_string_for_flatpickr(datetime)
      return nil if datetime.nil?

      datetime.strftime(TIME_FORMAT) if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include?(datetime.class)
    end

    def to_datetime_from_picker(datetime_string)
      return nil if datetime_string.nil?

      ::DateTime.strptime("#{datetime_string.upcase} #{Time.current.strftime('%z')}Z", TIME_FORMAT).to_time
    end
  end
end
