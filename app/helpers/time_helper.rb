# frozen_string_literal: true

require 'date'
require 'active_support/core_ext/date_and_time/compatibility'

module TimeHelper
  TIME_FORMAT = '%m/%d/%Y, %H:%M %P %Z'

  class << self
    def to_string_for_flatpickr(datetime)
      datetime.strftime(TIME_FORMAT) if [Date, DateTime, Time].include?(datetime.class)
    end

    def to_datetime_from_picker(datetime_string)
      ::DateTime.strptime("#{datetime_string.upcase} #{Time.now.strftime('%z')}Z", TIME_FORMAT).to_time
    end
  end
end
