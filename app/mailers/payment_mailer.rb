# frozen_string_literal: true

class PaymentMailer < ApplicationMailer
  include PaymentsHelper

  def payment_received(payment)
    self.payment = payment

    mail to: "#{@user.name} <#{@user.email}>",
         from: from_email,
         reply_to: reply_to_email,
         subject: "Your payment for #{@event.name} has been received"
  end

  private

  def payment=(payment)
    @payment = payment
    @ticket_request = @payment.ticket_request
    @event = @ticket_request&.event
    @user = @ticket_request&.user
  end
end
