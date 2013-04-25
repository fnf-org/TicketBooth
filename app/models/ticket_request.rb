class TicketRequest < ActiveRecord::Base
  STATUSES = [
    STATUS_PENDING = 'P',
    STATUS_APPROVED = 'A',
    STATUS_DECLINED = 'D',
  ]

  belongs_to :user
  belongs_to :event
  has_one :payment

  attr_accessible :user_id, :address, :adults, :kids, :cabins, :needs_assistance,
                  :notes, :status, :special_price, :event_id

  before_validation :convert_blanks_to_nil

  validates :user_id, presence: true, existence: true,
    uniqueness: { scope: :event_id,
                  message: 'has already requested a ticket for this event' }

  validates :event_id, presence: true, existence: true

  validates :status, inclusion: { in: STATUSES }

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

  scope :pending,  where(status: STATUS_PENDING)
  scope :approved, where(status: STATUS_APPROVED)
  scope :declined, where(status: STATUS_DECLINED)

  def can_view?(user)
    user && (user.site_admin? || user.id == user_id)
  end

  def pending?
    status == STATUS_PENDING
  end

  def approved?
    status == STATUS_APPROVED
  end

  def declined?
    status == STATUS_DECLINED
  end

  def price
    special_price ||
      adults * event.adult_ticket_price +
      kids * event.kid_ticket_price +
      cabins * event.cabin_price
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
