class PaymentMailer < ActionMailer::Base
  layout 'email'
  default from: "payments@cloudwatch.fm"

  def payment_received(payment)
    @payment = payment
    @ticket_request = @payment.ticket_request
    @event = @ticket_request.event
    @user = @ticket_request.user
    mail to: "#{@user.name} <#{@user.email}>",
         subject: "Your payment for #{@event.name} has been received"
  end
end
