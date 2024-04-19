# frozen_string_literal: true

module ShiftsHelper
  def volunteer_button_hover_text
    <<-TIP
      Sign up for this shift. You'll be able to un-volunteer or switch shifts
      until a few weeks before the event, at which point shifts will be
      finalized.
    TIP
  end

  def schedule_matrix
    interval = 30.minutes
    earliest = @event.time_slots.min_by(&:start_time).start_time
    latest   = @event.time_slots.max_by(&:end_time).end_time
    blocks   = (latest - earliest) / interval
    rows     = Array.new(blocks) { [] }

    @jobs.each do |job|
      last_time_slot = job
                       .time_slots
                       .sort_by(&:start_time)
                       .inject(nil) do |last_time_slot, time_slot|
        offset   = (time_slot.start_time - earliest) / interval
        duration = (time_slot.end_time - time_slot.start_time) / interval
        rows[offset] << { offset:, time_slot:, rowspan: duration.to_i }

        # Fill in empty gaps
        if last_time_slot && last_time_slot.end_time < time_slot.start_time
          offset   = (last_time_slot.end_time - earliest) / interval
          duration = (time_slot.start_time - last_time_slot.end_time) / interval
          rows[offset] << { offset:, rowspan: duration.to_i }
        elsif !last_time_slot && earliest < time_slot.start_time
          offset   = 0
          duration = (time_slot.start_time - earliest) / interval
          rows[offset] << { offset:, rowspan: duration.to_i }
        end

        # TODO: last_time_slot is always nil, since it's not set anywhere, right? -- @kigster
        time_slot
      end

      # Fill in any gaps at the end of a job
      if last_time_slot && last_time_slot.end_time < latest
        offset   = (last_time_slot.end_time - earliest) / interval
        duration = (latest - last_time_slot.end_time) / interval
        rows[offset] << { offset:, rowspan: duration.to_i }
      elsif !last_time_slot
        rows[0] << { offset: 0, rowspan: blocks }
      end
    end

    rows
  end
end
