# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    most_recent_event = Event.live_events.first
    error_message = 'No currently live events exist that have tickets on sale.'

    if most_recent_event.present?
      error_message = 'Please reach out to event coordinator to obtain the ticket request link.'
      if signed_in? && current_user.present?
        if current_user.site_admin? || current_user.manages_event?(most_recent_event)
          # event admin —> let them manage the event
          return redirect_to events_path(most_recent_event)

        elsif current_user.site_admin? || current_user.event_admin?
          # redirect event admins to the events listing
          return redirect_to events_path
        end

        # This user already has a ticket request, so redirect there
        if (ticket_request = TicketRequest.where(user: current_user).where(event: most_recent_event).last)
          return redirect_to event_ticket_request_path(event_id: most_recent_event.to_param, id: ticket_request.id)
        end

        # new ticket request
        return redirect_to new_event_ticket_request_path(event_id: most_recent_event.to_param)

      end

    elsif signed_in? && current_user && (current_user.site_admin? || current_user.event_admin?)

      # redirect event admins to the events listing
      return redirect_to events_path
    end

    # If we don't have any live events, render oops.
    @error_description = flash.now[:error] || error_message
    render :oops
  end

  def oops
    render
  end
end
