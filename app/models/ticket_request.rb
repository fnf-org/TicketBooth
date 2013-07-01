class TicketRequest < ActiveRecord::Base
  STATUSES = [
    STATUS_PENDING = 'P',
    STATUS_AWAITING_PAYMENT = 'A',
    STATUS_DECLINED = 'D',
    STATUS_COMPLETED = 'C',
  ]

  belongs_to :user
  belongs_to :event
  has_one :payment

  attr_accessible :user_id, :address, :adults, :kids, :cabins, :needs_assistance,
                  :notes, :status, :special_price, :event_id, :volunteer_shifts,
                  :performer

  before_validation :convert_blanks_to_nil

  validates :user_id, presence: true, existence: true,
    uniqueness: { scope: :event_id,
                  message: 'has already requested a ticket for this event' }

  validates :event_id, presence: true, existence: true

  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :address, presence: true

  validates :adults, presence: true,
    numericality: { only_integer: true, greater_than: 0 }

  validates :kids, allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :cabins, allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :volunteer_shifts, allow_nil: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :notes, length: { maximum: 500 }

  validates :special_price, allow_nil: true,
    numericality: { greater_than_or_equal_to: 0 }

  scope :completed, where(status: STATUS_COMPLETED)
  scope :pending,  where(status: STATUS_PENDING)
  scope :awaiting_payment, where(status: STATUS_AWAITING_PAYMENT)
  scope :approved, -> { awaiting_payment }
  scope :declined, where(status: STATUS_DECLINED)
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

  def free?
    price == 0
  end

  def total_tickets
    adults + kids
  end

private

  def convert_blanks_to_nil
    self.notes = nil if self.notes.blank?
    self.special_price = nil if self.special_price.blank?
  end
end
