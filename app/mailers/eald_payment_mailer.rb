# frozen_string_literal: true

class EaldPaymentMailer < ActionMailer::Base
  DEFAULT_SENDER_EMAIL = 'tickets@fnf.org'
  DEFAULT_REPLY_TO_EMAIL = 'tickets@fnf.org'

  add_template_helper(PaymentsHelper)

  layout 'email'

  def eald_payment_received(eald_payment)
    @eald_payment = eald_payment
    @event = @eald_payment.event
    mail to: "#{@eald_payment.name} <#{@eald_payment.email}>",
         from: from_email,
         reply_to: reply_to_email,
         subject: "Your payment for #{@event.name} Early Arrival/Late Departure passes has been received"
  end

  private

  def from_email
    "#{@event.name} <#{DEFAULT_SENDER_EMAIL}>"
  end

  def reply_to_email
    "#{@event.name} Ticketing <#{DEFAULT_REPLY_TO_EMAIL}>"
  end
end
