# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_requests
#
#  id                      :integer          not null, primary key
#  address_line1           :string(200)
#  address_line2           :string(200)
#  admin_notes             :string(512)
#  adults                  :integer          default(1), not null
#  agrees_to_terms         :boolean
#  cabins                  :integer          default(0), not null
#  car_camping             :boolean
#  car_camping_explanation :string(200)
#  city                    :string(50)
#  country_code            :string(4)
#  deleted_at              :datetime
#  donation                :decimal(8, 2)    default(0.0)
#  early_arrival_passes    :integer          default(0), not null
#  guests                  :text
#  kids                    :integer          default(0), not null
#  late_departure_passes   :integer          default(0), not null
#  needs_assistance        :boolean          default(FALSE), not null
#  notes                   :string(500)
#  previous_contribution   :string(250)
#  role                    :string(255)      default("volunteer"), not null
#  role_explanation        :string(200)
#  special_price           :decimal(8, 2)
#  state                   :string(50)
#  status                  :string(1)        not null
#  zip_code                :string(32)
#  created_at              :datetime
#  updated_at              :datetime
#  event_id                :integer          not null
#  user_id                 :integer          not null
#
# Indexes
#
#  index_ticket_requests_on_deleted_at  (deleted_at) WHERE (deleted_at IS NULL)
#
class TicketRequest < ApplicationRecord
  # Class methods
  class << self
    # @description
    #   This method returns a two-dimensional array. The first row is the header row,
    #   and then for each ticket request we return the primary user with the ticket request info,
    #   followed by one row per guest.
    def for_csv(event)
      table = []

      event.ticket_requests.active.each do |ticket_request|
        # Main Ticket Request User Row
        row = []

        row << ticket_request.user.name
        row << ticket_request.user.email
        row << 'No'
        row << ''

        csv_columns.each do |column|
          row << ticket_request.attributes[column]
        end

        table << row

        ticket_request.guests.each do |guest|
          age_string   = guest.include?(',') ? guest.gsub(/.*,/, '').strip : ''
          first, last, = guest.split(/[\s,]+/)
          email        = guest.include?('<') ? guest.gsub(/.*</, '').gsub(/>.*/, '') : ''

          next if "#{first} #{last}" == ticket_request.user.name || email == ticket_request.user.email

          kids_age = age_string.empty? ? '' : kids_age(age_string)

          table << ["#{first} #{last}", email, 'Yes', kids_age]
        end
      end

      table
    end

    def csv_header
      ['Name', 'Email', 'Guest?', 'Kids Age', *csv_columns.map(&:titleize)]
    end

    def csv_columns
      %w[
        address_line1
        address_line2
        city
        state
        zip_code
        country_code
        adults
        kids
        special_price
        donation
        needs_assistance
        status
        notes
        role
        role_explanation
        previous_contribution
        car_camping
        car_camping_explanation
        admin_notes
        early_arrival_passes
        late_departure_passes
      ]
    end

    private

    def kids_age(string)
      Integer(string)
    rescue StandardError
      ''
    end
  end

  # Deletions of TicketRequests are logical, not physical
  acts_as_paranoid

  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  STATUSES = [
    STATUS_PENDING          = 'P',
    STATUS_AWAITING_PAYMENT = 'A',
    STATUS_DECLINED         = 'D',
    STATUS_COMPLETED        = 'C',
    STATUS_REFUNDED         = 'R'
  ].freeze

  STATUS_NAMES = {
    'P' => 'Pending',
    'A' => 'Waiting for Payment',
    'D' => 'Declined',
    'C' => 'Completed',
    'R' => 'Refunded'
  }.freeze

  TICKET_LIMITS = {
    (ROLE_UBER_COORDINATOR = 'uber_coordinator') => 6,
    (ROLE_COORDINATOR = 'coordinator')           => 6,
    (ROLE_CONTRIBUTOR = 'contributor')           => 6,
    (ROLE_VOLUNTEER = 'volunteer')               => 6,
    (ROLE_OTHER = 'other')                       => 6
  }.freeze

  ROLES = {
    ROLE_UBER_COORDINATOR => 'Skipper/Board Member',
    ROLE_COORDINATOR      => 'Lead Coordinator',
    ROLE_CONTRIBUTOR      => 'Planner',
    ROLE_VOLUNTEER        => 'Volunteer',
    ROLE_OTHER            => 'Other (Art Grantee, a DJ, etc)'
  }.freeze

  belongs_to :user, inverse_of: :ticket_requests
  belongs_to :event, inverse_of: :ticket_requests

  has_one :payment, inverse_of: :ticket_request

  # Serialize guest emails as an array in a text field.
  serialize :guests, coder: Psych, type: Array

  attr_accessible :user_id, :adults, :kids, :cabins, :needs_assistance,
                  :notes, :status, :special_price, :event_id,
                  :user_attributes, :user, :donation, :role, :role_explanation,
                  :car_camping, :car_camping_explanation, :previous_contribution,
                  :address_line1, :address_line2, :city, :state, :zip_code,
                  :country_code, :admin_notes, :agrees_to_terms,
                  :early_arrival_passes, :late_departure_passes, :guests

  normalize_attributes :notes, :role_explanation, :previous_contribution,
                       :admin_notes, :car_camping_explanation

  accepts_nested_attributes_for :user

  before_validation :set_defaults

  validates :user, presence: { unless: -> { user.try(:new_record?) } }
  validates :event, presence: { unless: -> { event.try(:new_record?) } }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :address_line1, :city, :state, :zip_code, :country_code, presence: { if: -> { event.try(:require_mailing_address) } }
  validates :adults, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :early_arrival_passes, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :late_departure_passes, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :kids, allow_nil: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :cabins, allow_nil: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :role, presence: true, inclusion: { in: ROLES.keys }
  validates :role_explanation, presence: { if: -> { role == ROLE_OTHER } }, length: { maximum: 400 }
  validates :previous_contribution, length: { maximum: 250 }
  validates :notes, length: { maximum: 500 }
  validates :guests, length: { maximum: 10 }
  validates :special_price, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }
  validates :donation, numericality: { greater_than_or_equal_to: 0 }
  validates :agrees_to_terms, presence: true

  scope :completed, -> { where(status: STATUS_COMPLETED) }
  scope :pending, -> { where(status: STATUS_PENDING) }
  scope :awaiting_payment, -> { where(status: STATUS_AWAITING_PAYMENT) }
  scope :approved, -> { awaiting_payment }
  scope :declined, -> { where(status: STATUS_DECLINED) }
  scope :not_declined, -> { where.not(status: STATUS_DECLINED) }

  # Those TicketRequests that should be exported as a Guest List
  scope :active, -> { where(status: [STATUS_COMPLETED, STATUS_AWAITING_PAYMENT]) }

  def can_view?(user)
    self.user == user || event.admin?(user)
  end

  def owner?(user)
    self.user == user || event.admin?(user)
  end

  def status_name
    STATUS_NAMES[status]
  end

  def completed?
    status == STATUS_COMPLETED
  end

  def mark_complete
    Rails.logger.debug { "ticket request marking completed: #{id}" }
    update status: STATUS_COMPLETED
  end

  def pending?
    status == STATUS_PENDING
  end

  def approved?
    awaiting_payment?
  end

  def awaiting_payment?
    status == STATUS_AWAITING_PAYMENT
  end

  def approve
    update status: (free? ? STATUS_COMPLETED : STATUS_AWAITING_PAYMENT)
  end

  def declined?
    status == STATUS_DECLINED
  end

  def refunded?
    status == STATUS_REFUNDED
  end

  def mark_refunded
    Rails.logger.info { "ticket request marking refunded: #{id}" }
    update status: STATUS_REFUNDED
  end

  def payment_received?
    payment&.received?
  end

  # not able to purchase tickets in this state
  def can_purchase?
    !status.in? [STATUS_DECLINED, STATUS_PENDING]
  end

  def can_be_cancelled?(by_user:)
    user.id == by_user&.id && !payment_received?
  end

  def refund
    if refunded?
      errors.add(:base, 'Cannot refund a ticket that has already been refunded')
      return false
    elsif !completed? || !payment&.refundable?
      errors.add(:base, 'Cannot refund a ticket that has not been purchased')
      return false
    end

    # issue refund for payment
    Rails.logger.info { "ticket_request [#{id}] payment [#{payment.id}] refunding [#{payment.stripe_payment_id}]" }
    if payment.refund_payment
      mark_refunded
      true
    else
      Rails.logger.error { "ticket_request failed to refund [#{payment.stripe_payment_id}]" }
      false
    end
  end

  def price
    return special_price if special_price

    total = adults * event.adult_ticket_price

    if event.kid_ticket_price
      custom_price = event.price_rules.map do |price_rule|
        price_rule.calc_price(self)
      end.compact.min

      total += custom_price || (kids * event.kid_ticket_price)
    end

    total += cabins * event.cabin_price if event.cabin_price

    total
  end

  def cost
    price + donation
  end

  def free?
    price.zero?
  end

  def total_tickets
    adults + kids
  end

  def guest_count
    total_tickets
  end

  def guests_specified
    Array(guests).size
  end

  def guest_list
    [].tap do |guest_list|
      guest_list << user.name_and_email
      guests.each { |guest| guest_list << guest }
    end.compact
  end

  def all_guests_specified?
    guests_specified >= guest_count
  end

  def country_name
    ISO3166::Country[country_code]
  end

  def set_defaults
    self.status = nil if status.blank?
    self.status ||= if event
                      if event.tickets_require_approval
                        STATUS_PENDING
                      else
                        STATUS_AWAITING_PAYMENT
                      end
                    else
                      STATUS_PENDING
                    end

    # Remove empty guests
    # Note that guests are serialized as an array field.
    self.guests = Array(guests).map { |guest| guest&.strip }.select(&:present?).compact
  end
end
