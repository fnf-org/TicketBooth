# frozen_string_literal: true

module FnF
  class PaymentsService
    attr_accessor :ticket_request, :payment, :stripe_payment_intent, :user

    def initialize(ticket_request:)
      self.ticket_request = ticket_request
      raise ArgumentError, 'PaymentsService: ticket_request can not be nil' if ticket_request.nil?

      self.payment               = ticket_request.payment || ticket_request.build_payment
      self.stripe_payment_intent = payment.stripe_payment_intent || payment.build_stripe_payment_intent
    end

    # Stripe Payment Intent
    # https://docs.stripe.com/api/payment_intents/object
    def create_payment_intent(amount)
      Stripe::PaymentIntent.create({
                                     amount:                    payment.amount,
                                     currency:                  'usd',
                                     automatic_payment_methods: { enabled: true },
                                     description:               "#{ticket_request.total}#{ticket_request.event.name} Tickets",
                                     metadata:                  {
                                       ticket_request_id:      ticket_request.id,
                                       ticket_request_user_id: ticket_request.user_id,
                                       event_id:               ticket_request.event.id,
                                       event_name:             ticket_request.event.name
                                     }
                                   })
    end

    # @description Returns the Stripe Payment Intent
    # @see https://docs.stripe.com/api/payment_intents/object
    # @example
    # {
    #   "id": "pi_3MtwBwLkdIwHu7ix28a3tqPa",
    #   "object": "payment_intent",
    #   "amount": 2000,
    #   "amount_capturable": 0,
    #   "amount_details": {
    #     "tip": {}
    #   },
    #   "amount_received": 0,
    #   "application": null,
    #   "application_fee_amount": null,
    #   "automatic_payment_methods": {
    #     "enabled": true
    #   },
    #   "canceled_at": null,
    #   "cancellation_reason": null,
    #   "capture_method": "automatic",
    #   "client_secret": "pi_3MtwBwLkdIwHu7ix28a3tqPa_secret_YrKJUKribcBjcG8HVhfZluoGH",
    #   "confirmation_method": "automatic",
    #   "created": 1680800504,
    #   "currency": "usd",
    #   "customer": null,
    #   "description": null,
    #   "invoice": null,
    #   "last_payment_error": null,
    #   "latest_charge": null,
    #   "livemode": false,
    #   "metadata": {},
    #   "next_action": null,
    #   "on_behalf_of": null,
    #   "payment_method": null,
    #   "payment_method_options": {
    #     "card": {
    #       "installments": null,
    #       "mandate_options": null,
    #       "network": null,
    #       "request_three_d_secure": "automatic"
    #     },
    #     "link": {
    #       "persistent_token": null
    #     }
    #   },
    #   "payment_method_types": [
    #     "card",
    #     "link"
    #   ],
    #   "processing": null,
    #   "receipt_email": null,
    #   "review": null,
    #   "setup_future_usage": null,
    #   "shipping": null,
    #   "source": null,
    #   "statement_descriptor": null,
    #   "statement_descriptor_suffix": null,
    #   "status": "requires_payment_method",
    #   "transfer_data": null,
    #   "transfer_group": null
    # }
    def stripe_payment_intent(amount)
      intent = if stripe_payment_intent_id
        Stripe::PaymentIntent.retrieve(stripe_payment_intent_id)
      end

      if intent
        return intent if intent
      end

      Stripe::PaymentIntent.create({
                                     amount:,
                                     currency:                  'usd',
                                     automatic_payment_methods: { enabled: true },
                                     description:               "#{ticket_request.event.name} Tickets",
                                     metadata:                  {
                                       ticket_request_id:      ticket_request.id,
                                       ticket_request_user_id: ticket_request.user_id,
                                       event_id:               ticket_request.event.id,
                                       event_name:             ticket_request.event.name
                                     }
                                   })
    end

  end
end
