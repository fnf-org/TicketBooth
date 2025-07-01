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
require 'colorize'
require_relative '../config/environment'

module FnF
  unless defined?(Seeds)
    # rubocop: disable Rails/Output
    class Seeds
      unless defined?(SITE_ADMIN_PASSWORD)
        SITE_ADMIN_PASSWORD = 'fubar!'
        SITE_ADMIN_EMAIL    = 'site-admin@fnf.org'
        DEFAULT_USER_COUNT  = 10
        DEFAULT_EVENT_COUNT = 3
        HEADER_WIDTH        = 100
      end

      attr_reader :user_count, :event_count
      attr_accessor :users, :events, :site_admins, :ran

      def initialize(user_count: DEFAULT_USER_COUNT, event_count: DEFAULT_EVENT_COUNT)
        @user_count  = user_count
        @event_count = event_count
        @users       = []
        @site_admins = []
        @events      = []
        $stdout.sync = true
        @ran         = false
      end

      def run
        return if ran?

        create_site_admins
        create_users
        create_events
        self.ran = true
      end

      def ran?
        ran
      end

      private

      def create_site_admins
        header 'Creating Site Admins...'

        site_admin_user = User.where(email: SITE_ADMIN_EMAIL).first

        if site_admin_user && !site_admin_user.site_admin?
          site_admin_user.destroy
        end

        site_admin_user ||= User.create!(
          email: SITE_ADMIN_EMAIL,
          password: SITE_ADMIN_PASSWORD,
          password_confirmation: SITE_ADMIN_PASSWORD,
          confirmed_at: Time.zone.now,
          name: 'Site Administrator'
        )

        SiteAdmin.create!(user: site_admin_user) unless site_admin_user.site_admin?

        @site_admins << site_admin_user

        register_user(site_admin_user, new_user: true, password: SITE_ADMIN_PASSWORD)
      end

      def create_users
        current_user_count = User.count
        header "Current User Count: #{current_user_count}"

        current_users = User.all.to_a

        (0..user_count).to_a.each do |index|
          password = Faker::Internet.password
          new_user = true

          if current_users[index]
            password = nil
            new_user = false
          end

          user = current_users[index] || User.create!(
            email: Faker::Internet.email,
            password:,
            password_confirmation: password,
            confirmed_at: Time.zone.now,
            name: "#{Faker::Name.name}, The #{(index + 1).ordinalize}."
          )

          register_user(user, new_user:, password:)
        end

        header "Total Users Now: #{User.count}, Shown Users: #{users.size}"
      end

      def register_user(user, new_user: false, password: nil)
        @users << user unless users.include?(user)

        puts "  New User:     #{new_user ? 'Yes'.colorize(:light_green) : 'No'.colorize(:light_red)}"
        puts "  Name:         #{user.name.colorize(:light_green)}"
        puts "  Email:        #{user.email.colorize(:light_green)}"
        puts "  Password      #{password ? password.colorize(:light_blue) : 'Unknown'.colorize(:light_red)}"
        puts "  Site Admin?   #{user.site_admin? ? 'Yes'.colorize(:light_green) : 'No'.colorize(:light_red)}"
        puts "  Event Admin?  #{user.events_administrated.empty? ? 'No'.colorize(:light_red) : 'Yes'.colorize(:light_green)}"
        puts '  ——————————————————————————————————————————————————————————————— '
      end

      def create_events
        header "Events (Total Count: #{Event.count})"

        self.events = Event.all.to_a
        (0..event_count).to_a.each do |index|
          start_time = (Time.zone.today + index.months).to_time

          seasons = %w[Summer Fall Spring Winter].freeze

          event = events[index] || Event.create!(
            name: "#{seasons[index]} Campout ",
            adult_ticket_price: Faker::Commerce.price(range: 100...200),
            allow_donations: true,
            allow_financial_assistance: true,
            end_time: start_time + 3.days,
            require_mailing_address: true,
            kid_ticket_price: Faker::Commerce.price(range: 50...100),
            max_adult_tickets_per_request: 4,
            max_kid_tickets_per_request: 4,
            start_time:,
            venue: Faker::Address.street_address,
            ticket_sales_start_time: start_time - 1.month,
            ticket_sales_end_time: start_time - 1.month + 1.week,
            ticket_requests_end_time: start_time - 1.day,
            tickets_require_approval: true
          )

          @events << event unless events.include?(event)

          if event.admins.none?
            users.sample(Random.rand(2..4)).each do |u|
              event.make_admin(u)
            end
          end

          print_event(event)
        end
      end

      def print_event(event)
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

      def header(string)
        puts "\n#{format("  %-#{HEADER_WIDTH}.#{HEADER_WIDTH}s".colorize(background: :light_blue), string)}"
      end
    end
  end

  class << self
    attr_accessor :seeds
  end

  self.seeds ||= Seeds.new
end

FnF.seeds.run

# rubocop: enable Rails/Output
