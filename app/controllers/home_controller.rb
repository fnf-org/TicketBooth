class HomeController < ApplicationController
  def index
    if signed_in?
      most_recent_event = Event.order(id: :desc).first
      if current_user.site_admin? || current_user.event_admin?
        redirect_to events_path
      elsif ticket_request = TicketRequest.where(user_id: current_user)
                                          .where(event: most_recent_event).last
        redirect_to event_ticket_request_path(ticket_request.event, ticket_request)
      else
        most_recent_event = Event.order(id: :desc).first
        redirect_to new_event_ticket_request_path(event: most_recent_event)
      end
    end
  end
end
