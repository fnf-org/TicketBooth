# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  DEFAULT_SENDER_EMAIL = 'ticket-support@fnf.org'
  DEFAULT_REPLY_TO_EMAIL = 'ticket-support@fnf.org'

  layout 'email'

  abstract!

  protected

  def from_email
    "#{@event.name} <#{DEFAULT_SENDER_EMAIL}>" if defined?(:@event)
  end

  def reply_to_email
    "#{@event.name} Ticketing <#{DEFAULT_REPLY_TO_EMAIL}>" if defined?(:@event)
  end
end
