class TicketRequest < ActiveRecord::Base
  STATUSES = [
    STATUS_PENDING = 'P',
    STATUS_APPROVED = 'A',
    STATUS_DECLINED = 'D',
  ]

  attr_accessible :name, :email, :address, :adults, :kids, :cabins, :assistance,
                  :notes, :status

  validates_length_of :name, in: 2..70,
    too_short: 'is too short. Did you forget to enter it?',
    too_long: 'is too long. Perhaps remove middle names?'

  validates_length_of :notes, maximum: 500

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  validates_presence_of :name, :email, :address, :adults

  validates_inclusion_of :status, in: STATUSES

  validates_numericality_of :adults, :kids, :cabins, only_integer: true

  def pending?
    status == STATUS_PENDING
  end
end
