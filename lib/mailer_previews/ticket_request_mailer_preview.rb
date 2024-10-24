# frozen_string_literal: true

class TicketRequestMailerPreview < ActionMailer::Preview
  def email_ticket_holder
    ticket_request = TicketRequest.last
    subject = 'FnF Fall Classic - Important Information - Thank you!'
    body = "
Hi Friends and Family!
<p>
Thank you all for attending the 2024 FnF Fall Classic! We hope you had tons of fun! I know I did!<p>
Great music, perfect weather, and you!<br>
The Classic is one of my favorite events anywhere.<br>
Thank you for making this happen!
<p>
1) We have some outstanding payments for Car Camping ($50/car) and Late Departure ($30/person). <br>
If you have not already done so, please PayPal your balance to <b>paypal@cfaea.org</b>.
<p>
2) Lost and Found is here: https://docs.google.com/spreadsheets/d/1yy4mlnrt4wI5rYLPNau5iOzLSZo3YbuemBF_c59wsN0/edit?usp=sharing
<p>
3) Please join our FnF Slack! It's private and we use it for teams and groups to chat in real-time. https://join.slack.com/t/cfaea/shared_invite/zt-2mrpai15u-k3z3z92gr3y2GfFceGRLuQ
<p>
4) Please fill out the Fall Classic '24 retrospective questionnaire.
<br>
It can be totally anonymous, but if you'd like us to contact you, please include your email. <br>
There is also a space where you can get us your email if you'd like to volunteer in the future.<br>
https://forms.gle/gtdZN6WdNMFPctEE9
<p>
<p>
And please forward this email to your guests and invite them to join the FnF Planners group to get more involved. <br>
We had a lot of wonderful new people!
<p>
<p>
With love and gratitude, <br>
Bessie, Ethan, Joanna, Matt, Sticky
"
    TicketRequestMailer.with(ticket_request:).email_ticket_holder(ticket_request, subject, body)
  end
end
