class PaymentMailer < ActionMailer::Base
  layout 'email'
  default from: "payments@cloudwatch.fm"

  def payment_received(payment)
    @payment = payment
    @ticket_request = @payment.ticket_request
    mail to: "#{@ticket_request.name} <#{@ticket_request.email}>",
         subject: 'Your payment for Cloudwatch 2013 has been successfully received'
  end
end
