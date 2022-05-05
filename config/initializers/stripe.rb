# frozen_string_literal: true

#stripe_config = YAML.load_file("#{Rails.root}/config/stripe.yml")
Stripe.api_key = ENV['STRIPE_SECRET_KEY']
STRIPE_PUBLIC_KEY = ENV['STRIPE_PUBLIC_KEY']
