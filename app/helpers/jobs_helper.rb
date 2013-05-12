module JobsHelper
  def shift_length_options
    options_for_select([0.5, 1, 1.5, 2, 2.5, 4, 5, 6, 9, 12].map do |hours|
      ["#{hours} " + 'hour'.pluralize(hours), hours.hours]
    end)
  end

  def shift_overlap_options
    options_for_select(
      [['None', 0.minutes]] +
      [5, 10, 15, 20, 30].map do |mins|
        ["#{mins} minutes", mins.minutes]
      end)
  end
end
