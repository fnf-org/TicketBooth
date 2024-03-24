# frozen_string_literal: true

class PaymentReceivedMailer < ApplicationMailer
  def payment_received(payment)
    self.payment = payment

    mail to: "#{@user.name} <#{@user.email}>",
         from: from_email,
         reply_to: reply_to_email,
         subject: "Your payment for #{@event.name} has been received"
  end

  private

  def from_email
    "#{@event.name} <#{DEFAULT_SENDER_EMAIL}>"
  end

  def reply_to_email
    "#{@event.name} Ticketing <#{DEFAULT_REPLY_TO_EMAIL}>"
  end

  def payment=(payment)
    @payment = payment
    @ticket_request = @payment.ticket_request
    @event = @ticket_request&.event
    @user = @ticket_request&.user
  end
end
