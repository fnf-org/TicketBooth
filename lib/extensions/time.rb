class Time
  DATE_FORMATS.merge!(
    friendly: '%A, %B %-d, %Y %l:%M %p %Z',
    hmm: '%l:%M %p', # HMM = Hour minute meridian
  )

  def self.from_picker(datetimepicker_string)
    strptime(datetimepicker_string, '%Y/%m/%d %H:%M:%S').to_time
  end
end
