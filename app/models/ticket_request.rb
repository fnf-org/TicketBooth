# Individual request for one or more tickets.
#
# This is intended to capture as much information as possible about the ticket,
# as well as the state of the request.
class TicketRequest < ActiveRecord::Base
  STATUSES = [
    STATUS_PENDING = 'P',
    STATUS_AWAITING_PAYMENT = 'A',
    STATUS_DECLINED = 'D',
    STATUS_COMPLETED = 'C',
    STATUS_REFUNDED = 'R',
  ]

  TICKET_LIMITS = {
    (ROLE_UBER_COORDINATOR = 'uber_coordinator') => 8,
    (ROLE_COORDINATOR = 'coordinator') => 6,
    (ROLE_CONTRIBUTOR = 'contributor') => 4,
    (ROLE_VOLUNTEER = 'volunteer') => 2,
    (ROLE_OTHER = 'other') => 2,
  }

  ROLES = {
    ROLE_UBER_COORDINATOR => 'Skipper/Board Member',
    ROLE_COORDINATOR => 'Lead Coordinator',
    ROLE_CONTRIBUTOR => 'Planner',
    ROLE_VOLUNTEER => 'Volunteer',
    ROLE_OTHER => 'Other',
  }

  belongs_to :user
  belongs_to :event
  has_one :payment
  serialize :guests, Array

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

  validates :user, presence: { unless: -> { user.try(:new_record?) } }

  validates :event_id, presence: true

  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :address_line1, :city, :state, :zip_code, :country_code,
            presence: { if: -> { event.try(:require_mailing_address) } }

  validates :adults, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  validates :early_arrival_passes, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :late_departure_passes, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :kids, allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :cabins, allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :role, presence: true, inclusion: { in: ROLES.keys }
  validates :role_explanation, presence: { if: -> { role == ROLE_OTHER } },
                               length: { maximum: 200 }

  validates :notes, length: { maximum: 500 }

  validates :guests, length: { maximum: 8 }

  validates :special_price, allow_nil: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :donation, numericality: { greater_than_or_equal_to: 0 }

  validates :agrees_to_terms, presence: true

  scope :completed, -> { where(status: STATUS_COMPLETED) }
  scope :pending,  -> { where(status: STATUS_PENDING) }
  scope :awaiting_payment, -> { where(status: STATUS_AWAITING_PAYMENT) }
  scope :approved, -> { awaiting_payment }
  scope :declined, -> { where(status: STATUS_DECLINED) }
  scope :not_declined, -> { where('status != ?', STATUS_DECLINED) }

  before_validation do
    if event
      self.status ||= event.tickets_require_approval ? STATUS_PENDING
                                                     : STATUS_AWAITING_PAYMENT
    end

    # Remove empty guests
    self.guests = Array(self.guests).map { |guest| guest.strip.presence }.compact
  end

  def can_view?(user)
    self.user == user || event.admin?(user)
  end

  def completed?
    status == STATUS_COMPLETED
  end

  def mark_complete
    update_attributes status: STATUS_COMPLETED
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
    update_attributes status: (free? ? STATUS_COMPLETED : STATUS_AWAITING_PAYMENT)
  end

  def declined?
    status == STATUS_DECLINED
  end

  def refunded?
    status == STATUS_REFUNDED
  end

  def paid_via_credit?
    payment.try(:stripe_charge_id)
  end

  def refund
    if refunded?
      errors.add(:base, 'Cannot refund a ticket that has already been refunded')
      return false
    end

    unless payment
      errors.add(:base, 'Cannot refund a ticket that has not been purchased')
      return false
    end

    begin
      TicketRequest.transaction do
        Stripe::Charge.retrieve(payment.stripe_charge_id).refund
        return update_attributes(status: STATUS_REFUNDED)
      end
    rescue Stripe::StripeError => e
      errors.add(:base, "Cannot refund ticket: #{e.message}")
      return false
    end
  end

  def price
    return special_price if special_price

    total = adults * event.adult_ticket_price

    if event.kid_ticket_price
      custom_price = event.price_rules.map do |price_rule|
        price_rule.calc_price(self)
      end.compact.min

      total += custom_price ? custom_price : kids * event.kid_ticket_price
    end

    total += cabins * event.cabin_price if event.cabin_price

    total
  end

  def cost
    price + donation
  end

  def free?
    price == 0
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

  def all_guests_specified?
    guests_specified >= guest_count
  end

  def country_name
    ISO3166::Country[country_code]
  end
end
