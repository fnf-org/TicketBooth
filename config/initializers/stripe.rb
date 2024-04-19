# frozen_string_literal: true

require 'stripe'

TicketBooth::Application.config.x.stripe.secret_key = ENV.fetch('STRIPE_SECRET_KEY',
                                                                Rails.application.credentials[Rails.env.to_sym].stripe.secret_api_key)
TicketBooth::Application.config.x.stripe.public_key = ENV.fetch('STRIPE_PUBLIC_KEY',
                                                                Rails.application.credentials[Rails.env.to_sym].stripe.publishable_api_key)

Stripe.api_key = TicketBooth::Application.config.x.stripe.secret_key
