# frozen_string_literal: true

require 'date'
require 'active_support/core_ext/date_and_time/compatibility'

module TimeHelper
  TIME_FORMAT = '%m/%d/%Y, %H:%M %p %Z'
  DISPLAY_FORMAT = '%A, %d %B %Y, %H:%M %p'

  class << self
    def for_display(datetime)
      return nil if datetime.nil?

      datetime.strftime(DISPLAY_FORMAT) if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include?(datetime.class)
    end

    def to_string_for_flatpickr(datetime)
      return nil if datetime.blank?

      datetime.strftime(TIME_FORMAT) if [Date, DateTime, Time, ActiveSupport::TimeWithZone].include?(datetime.class)
    end

    def to_datetime_from_picker(datetime_string)
      return nil if datetime_string.nil?

      ::DateTime.strptime("#{datetime_string.upcase} #{Time.current.strftime('%z')}Z", TIME_FORMAT).to_time
    end

    # converts all values in hash to Time where key match '_time'
    def convert_times_for_db(in_hash)
      return in_hash if in_hash.blank?

      unless in_hash.is_a?(Hash)
        raise ArgumentError, "convert_times_for_db expects a Hash argument, got #{in_hash.class.name}"
      end

      converted_times = {}
      in_hash.keys.grep(/_time$/).each do |key|
        converted_times[key] = TimeHelper.to_datetime_from_picker(in_hash[key]) if in_hash[key].present?
      end

      in_hash.merge!(converted_times)
    end
  end
end
