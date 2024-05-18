# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    most_recent_event = Event.live_events.first

    if most_recent_event.present?
      if signed_in? && current_user.present?
        if current_user.site_admin? || current_user.manages_event?(most_recent_event)
          # event admin —> let them manage the event
          return redirect_to events_path(most_recent_event)

        elsif (ticket_request = TicketRequest.where(user: current_user)
                                             .where(event: most_recent_event).last)

          # This user already has a ticket request, so redirect there.s
          return redirect_to event_ticket_request_path(event_id: most_recent_event.to_param, id: ticket_request.id)
        elsif current_user.site_admin? || current_user.event_admin?

          # redirect event admins to the events listing
          return redirect_to events_path
        end
      end

      # Otherwise, redirect to the ticket request page for this event
      return redirect_to new_event_ticket_request_path(event_id: most_recent_event.to_param)
    elsif current_user.site_admin? || current_user.event_admin?

      # redirect event admins to the events listing
      return redirect_to events_path
    end

    # If we don't have any live events, render oops.
    @error_description = flash.now[:error] || no_events_message
    render :oops
  end

  def oops
    render
  end

  private

  def no_events_message
    'No currently live events exist that have tickets on sale.'
  end
end
