class TicketRequest < ActiveRecord::Base
  STATUSES = [
    STATUS_PENDING = 'P',
    STATUS_APPROVED = 'A',
    STATUS_DECLINED = 'D',
  ]

  belongs_to :user
  belongs_to :event
  has_one :payment

  attr_accessible :user_id, :address, :adults, :kids, :cabins, :assistance,
                  :notes, :status, :special_price, :event_id

  validates_length_of :notes, maximum: 500

  validates_presence_of :address, :adults

  validates_inclusion_of :status, in: STATUSES
  validates_uniqueness_of :user_id,
    message: 'has already recorded a ticket request.'

  validates_numericality_of :adults, :kids, :cabins, only_integer: true
  validates_numericality_of :special_price, allow_blank: true

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
    special_price || adults * 100 + kids * 50 # In dollars
  end

  def first_name
    name.split(' ').first
  end

  def total_tickets
    adults + kids
  end
end
