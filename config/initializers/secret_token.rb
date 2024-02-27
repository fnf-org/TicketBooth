# frozen_string_literal: true

secret_config = YAML.load_file(Rails.root.join('config/secret.yml').to_s)
TicketBooth::Application.config.secret_key_base = secret_config['secret_key_base']
