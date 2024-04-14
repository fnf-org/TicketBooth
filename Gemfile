# frozen_string_literal: true

source 'https://rubygems.org'

# Use main development branch of Rails
gem 'activesupport', '=7.1.3.2'
gem 'rails', '=7.1.3.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Use postgresql as the database for Active Record
gem 'pg'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 6'
gem 'puma-status'

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
# Use Redis adapter to run Action Cable in production
gem 'redis', '>= 4.0.1'

gem 'flatpickr'
gem 'newrelic_rpm'
gem 'sassc-rails'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]
# Reduces oot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'bootstrap', '~> 5.1'
gem 'jquery-rails', '~> 4.4'

gem 'colorize'
gem 'commonjs'
gem 'haml'
gem 'haml-rails'
gem 'twitter-bootstrap-rails'

gem 'attribute_normalizer'
gem 'country_select'
gem 'dalli'
gem 'devise'
gem 'protected_attributes_continued'
gem 'stripe'

gem 'annotate'
gem 'carrierwave'
gem 'mini_magick'
gem 'mini_racer'
gem 'psych'
gem 'rake'
gem 'ventable', '>= 1.3'

group :development, :test do
  gem 'awesome_print'
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
  gem 'stripe-ruby-mock', '~> 2.5.0', require: 'stripe_mock'
  gem 'yard'
end

group :development do
  gem 'asciidoctor'
  gem 'capistrano'
  gem 'rack-mini-profiler'
  gem 'web-console'
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
