# frozen_string_literal: true

class TicketRequestMailer < ActionMailer::Base
  DEFAULT_SENDER_EMAIL = 'fnftickets@gmail.com'
  DEFAULT_REPLY_TO_EMAIL = 'fnftickets@gmail.com'

  layout 'email'

  def request_received(ticket_request)
    @ticket_request = ticket_request
    @event = @ticket_request.event
    mail to: to_email,
         from: from_email,
         reply_to: reply_to_email,
         subject: "#{@event.name} ticket request confirmation"
  end

  def request_approved(ticket_request)
    @auth_token = ticket_request.user.generate_auth_token!
    @ticket_request = ticket_request
    @event = @ticket_request.event
    mail to: to_email,
         from: from_email,
         reply_to: reply_to_email,
         subject: "Your #{@event.name} ticket request has been approved!"
  end

  private

  def to_email
    "#{@ticket_request.user.name} <#{@ticket_request.user.email}>"
  end

  def from_email
    "#{@event.name} <#{DEFAULT_SENDER_EMAIL}>"
  end

  def reply_to_email
    "#{@event.name} Ticketing <#{DEFAULT_REPLY_TO_EMAIL}>"
  end
end
