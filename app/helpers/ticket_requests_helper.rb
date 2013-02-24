module TicketRequestsHelper
  def class_for_table_row(ticket_request)
    case ticket_request.status
    when 'P'
      'warning'
    when 'A'
      'success'
    when 'D'
      'error'
    end
  end

  def text_class_for_status(ticket_request)
    case ticket_request.status
    when 'P'
      'muted'
    when 'A'
      'text-success'
    when 'D'
      'text-error'
    end
  end

  def text_for_status(ticket_request)
    case ticket_request.status
    when 'P'
      'Pending'
    when 'A'
      'Approved'
    when 'D'
      'Declined'
    end
  end
end
