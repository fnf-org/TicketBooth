# frozen_string_literal: true

class EaldPaymentMailer < PaymentReceivedMailer
  def eald_payment_received(payment)
    @payment = payment
    @event = @payment.event
    mail to: "#{@payment.name} <#{@payment.email}>",
         from: from_email,
         reply_to: reply_to_email,
         subject: "Your payment for #{@event.name} Early Arrival/Late Departure passes has been received"
  end
end
