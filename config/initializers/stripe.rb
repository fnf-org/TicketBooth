stripe_config = YAML.load_file(Rails.root + 'config/stripe.yml')
Stripe.api_key = stripe_config['secret_key']
STRIPE_PUBLIC_KEY = stripe_config['public_key']
