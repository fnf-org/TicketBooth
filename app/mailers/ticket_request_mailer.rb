# frozen_string_literal: true

require 'awesome_print'

require_relative 'application_mailer'
require_relative '../concerns/routing'

class TicketRequestMailer < ApplicationMailer
  include ::Routing

  # The `request_received` method is used to send an email when a ticket request is received.
  # It sets the ticket request and then sends an email to the user who made the request.
  #
  # @param ticket_request [TicketRequest] The ticket request that has been received.
  # @return [Mail::Message] The email that has been prepared to be sent.
  def request_received(ticket_request)
    # Set the ticket request
    self.ticket_request = ticket_request

    @ticket_request_url = event_ticket_request_url(event_id: @event.id, id: @ticket_request.id)

    # Prepare the email to be sent
    mail to: to_email, # The recipient of the email
         from: from_email, # The sender of the email
         reply_to: reply_to_email, # The email address that will receive replies
         subject: "#{@event.name} ticket request confirmation" # The subject of the email
  end

  # The `request_approved` method is used to send an email when a ticket request is approved.
  # It sets the ticket request, generates an authentication token for the user, and then sends an email to the user.
  #
  # @param ticket_request [TicketRequest] The ticket request that has been approved.
  #
  # @return [Mail::Message, nil] The email that has been prepared to be sent, or nil if the authentication token is blank.
  def request_approved(ticket_request)
    # Set the ticket request
    self.ticket_request = ticket_request

    # Generate an authentication token for the user
    @auth_token = ticket_request&.user&.generate_auth_token!

    @payment_url = new_event_ticket_request_payment_url(@event, @ticket_request, @auth_token)

    if @event.eald?
      @extra_params = {}.tap do |params|
        params[:early_arrival_passes] = @ticket_request.early_arrival_passes
        params[:late_departure_passes] = @ticket_request.late_departure_passes
        params[:email] = @ticket_request.user.email
        params[:name] = @ticket_request.user.name
      end

      @eald_url = new_event_eald_payment_path(@event, @extra_params)
    end

    # Return if the authentication token is blank
    return if @auth_token.blank?

    # Prepare the email to be sent
    mail to: to_email, # The recipient of the email
         from: from_email, # The sender of the email
         reply_to: reply_to_email, # The email address that will ¬receive replies
         subject: "Your #{@event.name} ticket request has been approved!" # The subject of the email
  end

  private

  def ticket_request=(ticket_request)
    @ticket_request = ticket_request
    @event = @ticket_request&.event
  end

  def to_email
    "#{@ticket_request.user.name} <#{@ticket_request.user.email}>"
  end

  class << self
    def mail_config
      TicketBooth::Application.config.action_mailer
    end

    def ticket_request(event)
      request_received(event.ticket_request).tap do |mail|
        Rails.logger.info("delivering mail #{mail.inspect}")
        Rails.logger.info("mail config: #{mail_config.inspect}")
      end.deliver_later
    end

    def ticket_request_approved(event)
      request_approved(event.ticket_request).tap do |mail|
        Rails.logger.info("delivering mail #{mail.inspect}")
        Rails.logger.info("mail config: #{mail_config.inspect}")
      end.deliver_later
    end

    def ticket_request_declined(_)
      # Not yet implemented
    end
  end
end
