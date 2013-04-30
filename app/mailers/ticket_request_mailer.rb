class TicketRequestMailer < ActionMailer::Base
  layout 'email'
  default from: "no-reply@cloudwatch.fm"

  def request_received(ticket_request)
    @ticket_request = ticket_request
    @event = @ticket_request.event
    mail to: "#{@ticket_request.user.name} <#{@ticket_request.user.email}>",
         subject: "#{@event.name} ticket request confirmation"
  end

  def request_approved(ticket_request)
    @ticket_request = ticket_request
    @event = @ticket_request.event
    mail to: "#{@ticket_request.user.name} <#{@ticket_request.user.email}>",
         subject: "Your #{@event.name} ticket request has been approved!"
  end
end
