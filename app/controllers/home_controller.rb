# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if signed_in?
      most_recent_event = Event.order(id: :desc).first

      if most_recent_event.nil? || most_recent_event.id.nil?
        flash.now[:error] = 'No events have been defined.'
        redirect_to :oops

      elsif current_user.site_admin? || current_user.event_admin?
        redirect_to events_path

      elsif (ticket_request = TicketRequest.where(user: current_user)
                                           .where(event: most_recent_event).last)

        redirect_to event_ticket_request_path(event_id: most_recent_event.to_param, id: ticket_request.id)

      else
        redirect_to new_event_ticket_request_path(event_id: most_recent_event.to_param)
      end
    else
      render
    end
  end

  def oops
    flash.now[:error] = 'No events exist at the moment, please have your Site Administrator create a public event first.'
    render
  end
end
