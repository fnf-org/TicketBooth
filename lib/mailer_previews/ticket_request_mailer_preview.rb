# frozen_string_literal: true

class TicketRequestMailerPreview < ActionMailer::Preview
  def email_ticket_holder
    ticket_request = TicketRequest.last
    subject = 'FnF Fall Classic - Important Information'
    body = "Friends! Family!
<p>
The Classic is a week away! Holy carp!
<p>
VOLUNTEER!
<p>
FnF is a community driven by volunteerism. Our events are produced entirely by volunteers, for ourselves!<br>
<b>We can’t throw this event without *your* help!</b> <br>
Please sign up for a couple of shifts. You’ll get to meet awesome new people and have fun doing it!
<p>
The volunteer signup sheet: https://signup.app.fnf.org
<p>
If you are looking for a great way to contribute and want to meet a lot of people along the way, <br>
consider taking a shift as a Site Coordinator (SkC).
<p>
SC Sign up is here: https://forms.gle/jaM592Rc5fr6ZZH6A
<p>
WEATHER:
<p>
According to the weather forecast, it'll be in the mid to high 80s during the day, and low 60s to high 50s at night in Groveland, CA. <br>
Spinning Wheel is a microclimate environment and often has slightly different weather. Be prepared! <br>
We will continue to update the FC website with information as it comes our way.
<p>
ICE:
<p>
Unfortunately, we will not have ice for sale or a food truck on site. Please bring plenty of ice (freezing a gallon container of water is great). <br>
We will try and make an ice run for everyone on Saturday around noon.
<p>
WEBSITE:
<p>
We will continue to update The Fall Classic event page with all of the information a raver needs,
so check back before you go!<br>
https://fnf.events/2024-fall-classic
<p>
Friends and Family reminds you to <b>Leave No Trace!</b>
<p>
If you pack it in, you pack it out!<br>
This means that if the packaging, trash, cans, bottles, came with you, it goes home with you!
<p>
“Robot poop” is <b>NOT</b> recyclable. <b>Do not throw any in the trash or recycling!</b>
<p>
<p>
Excited to see all of you there!
"
    TicketRequestMailer.with(ticket_request:).email_ticket_holder(ticket_request, subject, body)
  end
end
