# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    live_events = Event.live_events
    most_recent_event = live_events&.first

    error_message = 'No currently live events exist that have tickets on sale.'
    Rails.logger.debug("home: user: #{current_user} event: #{most_recent_event}")

    if most_recent_event.present?
      error_message = 'Please reach out to event coordinator to obtain the ticket request link.'

      if signed_in? && current_user.present?
        # redirect event admins to the events listing
        if current_user.site_admin? || current_user.event_admin?
          return redirect_to events_path
        end

        # This user already has a ticket request, so redirect there
        if (ticket_request = TicketRequest.where(user: current_user).where(event: live_events.ids).last)
          return redirect_to event_ticket_request_path(event_id: ticket_request.event_id, id: ticket_request.id)
        end
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
