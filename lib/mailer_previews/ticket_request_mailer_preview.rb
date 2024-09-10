class TicketRequestMailerPreview < ActionMailer::Preview
  def email_ticket_holder
    ticket_request = TicketRequest.last
    subject = 'Test Subject'
    body = "This is my message test
<p>
We care deeply about the health, safety, and comfort of attendees at our events
and member of our community. <br>
To help achieve this, we ask all of our members and guests to read,
and abide by our <a href='https://fnf.page.link/coc'>Code Of Conduct</a>
<p>
We ask that you share this with each of your guests whom you may bring to the event.
<p>
We are a community driven by volunteerism in the service of the community.
<p>
As such, we depend upon the energy and vision of members and guests to make our events happen!<br>
Please (re)acquaint yourself with The FnF Way, https://cfaea.net/the-fnf-way/,<br>
and get involved with helping make the event happen!
"
    TicketRequestMailer.with(ticket_request:).email_ticket_holder(ticket_request, subject, body)
  end
end
