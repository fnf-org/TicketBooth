class HomeController < ApplicationController
  def index
    if signed_in?
      if current_user.site_admin? || current_user.event_admin?
        redirect_to events_path
      elsif ticket_request = TicketRequest.where(user_id: current_user).last
        redirect_to event_ticket_request_path(ticket_request.event, ticket_request)
      end
    end
  end
end
