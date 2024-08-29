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
         subject: "#{@event.name} ticket request received!" # The subject of the email
  end

  # The `request_confirmed` method is used to send an email when a ticket request is confirmed without approval.
  # It sets the ticket request and then sends an email to the user who made the request.
  #
  # @param ticket_request [TicketRequest] The ticket request that has been confirmed
  # @return [Mail::Message] The email that has been prepared to be sent.
  def request_confirmed(ticket_request)
    # Set the ticket request
    self.ticket_request = ticket_request

    # Generate an authentication token for the user
    @auth_token = ticket_request&.user&.generate_auth_token!

    # Return if the authentication token is blank
    if @auth_token.blank?
      Rails.logger.warn { "request_confirmed: no auth token for user: #{@ticket_request.inspect}" }
      return
    end

    @payment_url = new_event_ticket_request_payment_url(@event, @ticket_request, @auth_token)
    @ticket_request_url = event_ticket_request_url(event_id: @event.id, id: @ticket_request.id)
    Rails.logger.debug { "request_confirmed: payment_url: #{@payment_url} ticket_request_url: #{@ticket_request_url}" }

    # Prepare the email to be sent
    mail to: to_email, # The recipient of the email
         from: from_email, # The sender of the email
         reply_to: reply_to_email, # The email address that will receive replies
         subject: "#{@event.name} ticket confirmation!" # The subject of the email
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

    # Return if the authentication token is blank
    return if @auth_token.blank?

    @payment_url = new_event_ticket_request_payment_url(@event, @ticket_request, @auth_token)
    @ticket_request_url = event_ticket_request_url(event_id: @event.id, id: @ticket_request.id)

    # Prepare the email to be sent
    mail to: to_email, # The recipient of the email
         from: from_email, # The sender of the email
         reply_to: reply_to_email, # The email address that will ¬receive replies
         subject: "Your #{@event.name} ticket request has been approved!" # The subject of the email
  end

  # The `request_denied` method is used to send an email when a ticket request is denied for reasons.
  # @param ticket_request [TicketRequest] The ticket request that has been denied.
  #
  # @return [Mail::Message, nil] The email that has been prepared to be sent, or nil if the authentication token is blank.
  def request_denied(ticket_request)
    # Set the ticket request
    self.ticket_request = ticket_request

    # Prepare the email to be sent
    mail to: to_email, # The recipient of the email
         from: from_email, # The sender of the email
         reply_to: reply_to_email, # The email address that will ¬receive replies
         subject: "Your #{@event.name} ticket request" # The subject of the email
  end

  # The `payment_reminder` method is used to send an email to all ticket requests awaiting payment
  #
  # @param ticket_request [TicketRequest] The ticket request that has been confirmed
  # @return [Mail::Message] The email that has been prepared to be sent.
  def payment_reminder(ticket_request)
    # Set the ticket request
    self.ticket_request = ticket_request

    # Generate an authentication token for the user
    @auth_token = ticket_request.user.generate_auth_token!
    Rails.logger.debug { "payment_reminder: ticket_request: #{ticket_request.inspect} user: #{ticket_request.user.id} auth_token: #{@auth_token}" }

    # Return if the authentication token is blank
    if @auth_token.blank?
      Rails.logger.warn { "payment_reminder: no auth token for user: #{@ticket_request.inspect}" }
      return
    end

    @payment_url = new_event_ticket_request_payment_url(event_id: @event.id, ticket_request_id: @ticket_request.id, user_token: @auth_token)
    @ticket_request_url = event_ticket_request_url(event_id: @event.id, id: @ticket_request.id)
    Rails.logger.debug { "payment_reminder: ticket_request_id: #{ticket_request.id} payment_url: #{@payment_url} ticket_request_url: #{@ticket_request_url}" }

    # Prepare the email to be sent
    mail to: to_email, # The recipient of the email
         from: from_email, # The sender of the email
         reply_to: reply_to_email, # The email address that will receive replies
         subject: "#{@event.name} buy your tickets now!" # The subject of the email
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
      request_received(event.ticket_request).deliver_later
    end

    def ticket_request_confirmed(event)
      request_confirmed(event.ticket_request).deliver_later
    end

    def ticket_request_approved(event)
      request_approved(event.ticket_request).deliver_later
    end

    def ticket_request_declined(event)
      request_denied(event.ticket_request).deliver_later
    end
  end
end
