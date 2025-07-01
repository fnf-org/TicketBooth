# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Ticket Booth** is a Ruby on Rails application for managing ticket sales and volunteer coordination for community events. It supports ticket requests, payments via Stripe, event management, and volunteer job coordination.

## Architecture

### Core Models

- **Event**: Central entity representing an event with ticket sales, pricing, and scheduling
- **TicketRequest**: User requests for tickets with approval workflow (Pending -> Awaiting Payment -> Completed/Declined/Refunded)
- **User**: Authentication via Devise with site admin and event admin roles
- **Payment**: Stripe integration for payment processing
- **Addon**: Additional purchasable items (passes, camping permits) via EventAddon join model
- **Job/TimeSlot/Shift**: Volunteer work coordination system

### Key Features

- Multi-status ticket approval workflow
- Stripe payment integration with refund support
- Role-based access (Site Admin, Event Admin, Users)
- Event-specific add-ons (camping, passes)
- Guest list management and CSV export
- Email notifications via ActionMailer
- VCR cassettes for API testing

## Development Commands

### Setup

```bash
bin/dev-setup        # Complete environment setup (macOS only)
bin/dev-start        # Start development server (uses Foreman)
make dev             # Alternative: install deps + start server
```

### Database

```bash
bin/rails db:create             # Create databases
bin/rails db:migrate:with_data  # Run migrations with data migrations
bin/rails db:seed               # Seed development data  
bin/rails db:test:prepare       # Prepare test DB
make reset                      # Complete DB reset + tests
```

### Testing & Quality

```bash
bundle exec rspec               # Run test suite
bundle exec rubocop             # Lint Ruby code
bin/shchk                       # ShellCheck for shell scripts
make ci                         # Run full CI suite locally
```

### Assets

```bash
yarn install                    # Install Node dependencies
yarn run build                  # Build JavaScript assets
yarn run build:css              # Build CSS assets  
yarn run assets                 # Build all assets
```

### Production Deployment

```bash
bin/deploy                    # Deploy to production (requires whitelisted IP)
```

Alternatively, and assuming your SSH key is in the `authorized_keys` on the remote server, you can:

```bash
bundle exec cap production deploy
```

## Development Notes

### Server Startup

- **Must** use `bin/dev-start` or `foreman start -f Procfile.dev` - not `rails s`
- Foreman starts Rails server + asset watchers for CSS/JS compilation
- Default port: 3000 (configurable via PORT env var)

### Database Schema
- Uses SQL schema format (`config.active_record.schema_format = :sql`)
- Includes data migrations via `data_migrate` gem
- Paranoid deletions on TicketRequest model

### Payment Integration
- Stripe integration in Payment model
- Payment states: pending, received, refunded
- VCR cassettes in `spec/fixtures/vcr_cassettes/` for API testing

### Authentication & Authorization
- Devise for user authentication with confirmation, lockable, trackable modules
- Site admins can manage all events
- Event admins can manage specific events
- Users can only edit their own ticket requests

### Asset Pipeline
- Uses Propshaft (not Sprockets)
- esbuild for JavaScript bundling
- Sass for CSS compilation with Bootstrap 5
- Assets built to `app/assets/builds/`

### Testing
- RSpec test suite with FactoryBot
- VCR for external API mocking
- SimpleCov for coverage
- Brakeman for security scanning

### Linting & Code Quality
- RuboCop with Rails and RSpec cops
- relaxed-rubocop configuration  
- ShellCheck for shell scripts
- Annotate gem for model schema comments
