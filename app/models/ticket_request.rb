class TicketRequest < ActiveRecord::Base
  STATUSES = [
    STATUS_PENDING = 'P',
    STATUS_APPROVED = 'A',
    STATUS_DECLINED = 'D',
  ]

  belongs_to :user
  has_one :payment

  attr_accessible :user_id, :address, :adults, :kids, :cabins, :assistance, :notes, :status

  validates_length_of :notes, maximum: 500

  validates_presence_of :address, :adults

  validates_inclusion_of :status, in: STATUSES
  validates_uniqueness_of :user_id,
    message: 'has already recorded a ticket request.'

  validates_numericality_of :adults, :kids, :cabins, only_integer: true

  def can_view?(user)
    user && (user.site_admin? || user.id == user_id)
  end

  def pending?
    status == STATUS_PENDING
  end

  def price
    adults * 100 + kids * 50 # In dollars
  end

  def first_name
    name.split(' ').first
  end

  def total_tickets
    adults + kids
  end
end
