require 'stripe'

Stripe.api_key = Rails.configuration.stripe[:secret_api_key]
