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
    ROLE_UBER_COORDINATOR => 'Uber Coordinator',
    ROLE_COORDINATOR => 'Coordinator',
    ROLE_CONTRIBUTOR => 'Major Contributor',
    ROLE_VOLUNTEER => 'Working Shifts',
    ROLE_OTHER => 'Other',
  }

  belongs_to :user
  belongs_to :event
  has_one :payment

  attr_accessible :user_id, :address, :adults, :kids, :cabins, :needs_assistance,
                  :notes, :status, :special_price, :event_id, :volunteer_shifts,
                  :user_attributes, :user, :donation, :role, :role_explanation,
                  :vehicle_camping_requested

  normalize_attributes :notes, :role_explanation

  accepts_nested_attributes_for :user

  validates :user, presence: true, existence: { unless: -> { user.try(:new_record?) } }

  validates :event_id, presence: true, existence: true

  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :address, presence: { if: -> { event.try(:require_mailing_address) } }

  validates :adults, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  validates :kids, allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :cabins, allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :role, presence: true, inclusion: { in: ROLES.keys }
  validates :role_explanation, presence: { if: -> { role == ROLE_OTHER } },
                               length: { maximum: 200 }

  validates :volunteer_shifts, allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :notes, length: { maximum: 500 }

  validates :special_price, allow_nil: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :donation, numericality: { greater_than_or_equal_to: 0 }

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
end
