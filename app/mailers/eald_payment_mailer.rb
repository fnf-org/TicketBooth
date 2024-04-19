# frozen_string_literal: true

class EaldPaymentMailer < ApplicationMailer
  def eald_payment_received(eald_payment)
    @eald_payment = eald_payment
    @event = @eald_payment.event
    mail to: "#{@eald_payment.name} <#{@eald_payment.email}>",
         from: from_email,
         reply_to: reply_to_email,
         subject: "Your payment for #{@event.name} Early Arrival/Late Departure passes has been received"
  end
end
