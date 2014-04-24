class MandrillMailer < ActionMailer::Base
  def inbound_email(message)
    mail to: 'shane@dasilva.io',
         from: "#{message['from_name']} <forward@helpingculture.com>",
         reply_to: "#{message['from_name']} <#{message['from_email']}>",
         subject: message['subject'] do |format|
      format.text { render text: message['text'] }
      format.html { render text: message['html'] }
    end
  end
end
