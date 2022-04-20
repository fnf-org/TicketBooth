secret_config = YAML.load_file(Rails.root + 'config/secret.yml')
TicketBooth::Application.config.secret_key_base = secret_config['secret_key_base']
