# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#

require 'faker'

# rubocop: disable Rails/Output
class Seeds
  SITE_ADMIN_PASSWORD = 'fubar'
  SITE_ADMIN_EMAIL = 'site-admin@fnf.org'
  DEFAULT_USER_COUNT = 100
  DEFAULT_EVENT_COUNT = 10
  HEADER_WIDTH = ENV.fetch('COLUMNS', 80).to_i

  attr_reader :user_count, :event_count
  attr_accessor :users, :events, :site_admin

  def initialize(user_count: DEFAULT_USER_COUNT, event_count: DEFAULT_EVENT_COUNT)
    @user_count = user_count
    @event_count = event_count
  end

  def run
    create_site_admin
    create_users
    create_events
  end

  private

  def header(string)
    puts "\n#{format("  %-#{HEADER_WIDTH}.#{HEADER_WIDTH}s".colorize(background: :light_blue), string)}"
  end

  def create_users
    self.users = if User.count >= user_count
                   User.limit(10)
                 else
                   user_count.times do
                     password = Faker::Internet.password
                     User.create!(
                       email: Faker::Internet.email,
                       password:,
                       password_confirmation: password,
                       confirmed_at: Time.zone.now,
                       name: Faker::Name.name
                     )
                   end
                 end
    print_users(users)
  end

  def print_users(users)
    header "Users (Total Count: #{User.count})"

    users.each do |user|
      next if user.email == SITE_ADMIN_EMAIL

      puts "  Email:     #{user.email.colorize(:light_green)}"
      puts "  Name:      #{user.name.colorize(:light_green)}"
      puts
    end
  end

  def create_site_admin
    @site_admin = User.where(email: SITE_ADMIN_EMAIL).first || User.create!(
      email: SITE_ADMIN_EMAIL,
      password: SITE_ADMIN_PASSWORD,
      password_confirmation: SITE_ADMIN_PASSWORD,
      confirmed_at: Time.zone.now,
      name: 'Site Administrator'
    )

    SiteAdmin.create!(user: @site_admin) unless SiteAdmin.exists?(user: @site_admin)

    print_site_admin
  end

  def print_site_admin
    header "Site Administrator (Total Count: #{SiteAdmin.count})"
    puts
    puts "  Email:     #{site_admin.email.colorize(:yellow)}"
    puts "  Name:      #{site_admin.name.colorize(:yellow)}"
    puts "  Password:  #{SITE_ADMIN_PASSWORD.colorize(:yellow)}"
    puts
  end

  def create_events
    @events = if Event.count >= event_count
                Event.limit(10)
              else
                create_events!
              end

    print_events(events)
  end

  def create_events!
    (0..event_count).to_a.map do
      start_time = (Time.zone.today + Random.rand(2..3).months).to_time
      Event.create!(
        adult_ticket_price: Faker::Commerce.price(range: 100...200),
        allow_donations: true,
        allow_financial_assistance: true,
        cabin_price: Faker::Commerce.price(range: 150..300),
        early_arrival_price: 25.00,
        end_time: start_time + 3.days,
        require_mailing_address: true,
        kid_ticket_price: Faker::Commerce.price(range: 50...100),
        late_departure_price: Faker::Commerce.price(range: 15...25),
        max_adult_tickets_per_request: 4,
        max_cabin_requests: 2,
        max_cabins_per_request: 1,
        max_kid_tickets_per_request: 4,
        name: "FnF Event: #{Faker::Company.name}",
        start_time:,
        venue: Faker::Address.street_address,
        ticket_sales_start_time: start_time - 1.month,
        ticket_sales_end_time: start_time - 1.month + 1.week,
        ticket_requests_end_time: start_time - 1.day,
        tickets_require_approval: true
      ).tap do |event|
        3.times do
          admin = users.sample
          event.make_admin(admin)
        end
      end
    end
  end

  def print_events(events)
    header "Events (Total Count: #{Event.count})"

    events.each do |event|
      puts
      puts "  Name:                    #{event.name.to_s.colorize(color: :magenta, mode: :bold)}"
      puts "  Start Time:              #{event.start_time.to_s.colorize(:light_yellow)}"
      puts "  End Time:                #{event.end_time.to_s.colorize(:light_yellow)}"
      puts "  Ticket Sales Start Time: #{event.ticket_sales_start_time.to_s.colorize(:light_yellow)}"
      puts "  Ticket Sales End Time:   #{event.end_time.to_s.colorize(:light_yellow)}"
      puts
      puts '  Event Admins: '.colorize(background: :green)

      event.reload.event_admins.each do |event_admin|
        puts "    #{event_admin.user.name.colorize(:light_green)} <#{event_admin.user.email.colorize(:light_green)}>"
      end
    end
  end
end

Seeds.new.run

# rubocop: enable Rails/Output
