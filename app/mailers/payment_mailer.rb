class PaymentMailer < ActionMailer::Base
  layout 'email'
  default from: "payments@cloudwatch.fm"

  def payment_received(payment)
    @payment = payment
    @ticket_request = @payment.ticket_request
    @event = @ticket_request.event
    mail to: "#{@ticket_request.name} <#{@ticket_request.email}>",
         subject: "Your payment for #{@event.name} has been received"
  end
end
