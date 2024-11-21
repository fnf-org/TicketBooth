# frozen_string_literal: true

source 'https://rubygems.org'

ruby File.read('.ruby-version')

# Use main development branch of Rails
gem 'data_migrate'
gem 'rails', '=8.0.0.beta1'

# Unclear if we need to require it explicitly
# gem 'activesupport', '=7.1.3.2'

#  Use postgresql as the database for Active Record
gem 'pg'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 6'
gem 'puma-status'

# replace sprockets with propshaft
gem 'propshaft'

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem 'jsbundling-rails'
# Hotwire"s SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'
# Hotwire"s modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem 'cssbundling-rails'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Gems that used to be in Standard Library, but are no longer
gem 'csv'     # removed from stdlib with ruby 3.4
gem 'logger'  # removed from stdlib with ruby 3.5

# Redis
gem 'redis' # , '>= 4.0.1'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt' # , '~> 3.1.7'

# Report APM info to NewRelic
gem 'newrelic_rpm'

# Lograge
gem 'lograge'
gem 'logstash-event'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces oot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"
# gem 'twitter-bootstrap-rails'
# gem 'bootstrap', '~> 5.1'
# gem 'jquery-rails', '~> 4.4'
# gem 'commonjs'

# Modern Date Picker
gem 'country_select'
gem 'flatpickr'

gem 'colorize'
gem 'hashie'

gem 'haml'
gem 'haml-rails'

gem 'annotate'
gem 'attribute_normalizer'
gem 'awesome_print'
gem 'carrierwave'
gem 'dalli'
gem 'devise'
gem 'mini_magick'
# gem 'mini_racer', git: 'https://github.com/rubyjs/mini_racer', platforms: :ruby
gem 'protected_attributes_continued'
gem 'psych'
gem 'rake'
gem 'stripe', '~> 13.2'
gem 'ventable', '>= 1.3'
gem 'yard'

group :development, :test do
  gem 'brakeman', require: false
  gem 'codecov'
  gem 'debug', platforms: %i[mri windows]
  gem 'faker'
  gem 'foreman'
  gem 'relaxed-rubocop'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rails-omakase', require: false
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'asciidoctor'
  # gem 'rack-mini-profiler'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console'
end

group :development, :deploy do
  gem 'bcrypt_pbkdf'
  gem 'capistrano'
  gem 'capistrano-faster-assets'
  gem 'capistrano-rails'
  gem 'capistrano-rake', require: false
  gem 'capistrano-rbenv'
  gem 'capistrano-slackify', '~> 2.10', require: false
  gem 'ed25519'
end

group :test do
  gem 'accept_values_for'
  gem 'factory_bot_rails'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'timecop'
  gem 'timeout'
end

gem 'paranoia'
