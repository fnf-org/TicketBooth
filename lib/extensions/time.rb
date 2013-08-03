class Time
  DATE_FORMATS.merge!(
    friendly: '%A, %B %-d, %Y %l:%M %p %Z',
    month_day: '%B %-d',
    hmm: '%l:%M %p', # HMM = Hour minute meridian
    dhmm: '%A, %l:%M %p', # DayOfWeek, HMM
  )

  def self.from_picker(datetimepicker_string)
    strptime(datetimepicker_string, '%Y/%m/%d %H:%M:%S').to_time unless datetimepicker_string.blank?
  end
end
