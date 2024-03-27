# frozen_string_literal: true

class Time
  TIME_FORMAT = '%Y/%m/%d %H:%M:%S'

  DATE_FORMATS.merge!(
    friendly: '%A, %B %-d, %Y %l:%M %p %Z',
    month_day: '%B %-d',
    hmm: '%l:%M %p', # HMM = Hour minute meridian
    dhmm: '%A, %l:%M %p' # DayOfWeek, HMM
  )

  def self.from_picker(datetimepicker_string)
    strptime(datetimepicker_string, TIME_FORMAT).to_time if datetimepicker_string.present?
  end
end
