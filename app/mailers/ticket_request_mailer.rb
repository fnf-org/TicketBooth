class TicketRequestMailer < ActionMailer::Base
  DEFAULT_SENDER_EMAIL = 'events@helpingculture.com'

  layout 'email'

  def request_received(ticket_request)
    @ticket_request = ticket_request
    @event = @ticket_request.event
    mail to: to_email,
         from: from_email,
         subject: "#{@event.name} ticket request confirmation"
  end

  def request_approved(ticket_request)
    @ticket_request = ticket_request
    @event = @ticket_request.event
    mail to: to_email,
         from: from_email,
         subject: "Your #{@event.name} ticket request has been approved!"
  end

private

  def to_email
    "#{@ticket_request.user.name} <#{@ticket_request.user.email}>"
  end

  def from_email
    "#{@event.name} <#{DEFAULT_SENDER_EMAIL}>"
  end
end
