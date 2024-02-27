# frozen_string_literal: true

Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY', nil)
STRIPE_PUBLIC_KEY = ENV.fetch('STRIPE_PUBLIC_KEY', nil)
