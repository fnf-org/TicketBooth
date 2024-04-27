# frozen_string_literal: true

require 'date'
require 'active_support/core_ext/date_and_time/compatibility'

# @description
#   A helper module for converting datetime objects to and from
#   string representations on both the forms and the views.
module TimeHelper
  class DateTimeParsingError < Date::Error; end

  DATE_FORMAT = '%m/%d/%Y'

  # NOTE: This format must match the format defined for the
  # flatpickr JS library, otherwise the forms won't set the time
  # correctly.
  TIME_FORMAT = "#{DATE_FORMAT}, %H:%M %p %Z".freeze

  # NOTE: This format is for displaying on the readonly pages only
  DISPLAY_FORMAT = '%A, %B %-d, %Y @ %H:%M %p'

  class << self
    # @description
    #   Converts a datetime stored in the database to a string format
    #   suitable for displaying in the readonly views of an Event
    TIME_CLASSES = [Date, DateTime, Time, ActiveSupport::TimeWithZone].freeze

    def for_display(datetime)
      return nil if datetime.nil?

      datetime.strftime(DISPLAY_FORMAT) if TIME_CLASSES.include?(datetime.class)
    end

    # @description
    #   Converts a datetime stored in the database to a string format
    #   suitable for displaying on the form and wired to Flatpickr.
    def to_flatpickr(datetime)
      return nil if datetime.blank?

      datetime.strftime(TIME_FORMAT) if TIME_CLASSES.include?(datetime.class)
    end

    # @description
    #   Converts the string received from the Flatpickr widget to a datetime
    #   object suitable for saving in the database.
    def from_flatpickr(datetime_string)
      return nil if datetime_string.nil?

      datetime_string_input = "#{datetime_string.upcase} #{Time.current.strftime('%z')}Z"
      ::DateTime
        .strptime(datetime_string_input, TIME_FORMAT)
        .to_time
    rescue Date::Error => e
      Rails.logger.error("ERROR parsing [#{datetime_string_input}] for format #{TIME_FORMAT}: #{e.message}")
      raise e
    end

    # @description
    #   Converts all values in a given hash corresponding
    #   to the keys that end with "_time" to the format suitable for storing in
    #   the database.
    # @param attrs Event attributes hash with symbolized keys
    def normalize_time_attributes(attrs)
      return attrs if attrs.blank?

      unless attrs.is_a?(Hash)
        raise ArgumentError, "normalize_time_attributes() expects a Hash argument, got #{attrs.class.name}"
      end

      attrs.each do |key, value|
        attrs[key] = TimeHelper.from_flatpickr(value) if key.to_s =~ /_time$/ && attrs[key].present?
      end
    end
  end
end
