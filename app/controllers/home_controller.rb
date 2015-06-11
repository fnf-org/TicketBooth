class HomeController < ApplicationController
  def index
    if signed_in?
      if current_user.site_admin? || current_user.event_admin?
        redirect_to events_path
      elsif ticket_request = TicketRequest.where(user_id: current_user)
                                          .where(event_id: 3).last # TODO: Need something better
        redirect_to event_ticket_request_path(ticket_request.event, ticket_request)
      else
        # TODO: Figure out some clever approach for this
        redirect_to new_event_ticket_request_path(event_id: 3)
      end
    end
  end
end
