class TicketRequestMailer < ActionMailer::Base
  layout 'email'
  default from: "no-reply@cloudwatch.fm"

  def request_approved(ticket_request)
    @ticket_request = ticket_request
    mail to: "#{@ticket_request.name} <#{@ticket_request.email}>",
         subject: 'Your Cloudwatch ticket request has been approved!'
  end
end
