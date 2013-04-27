class Event < ActiveRecord::Base
  has_many :event_admins
  has_many :jobs, dependent: :destroy
  has_many :ticket_requests, dependent: :destroy

  MAX_NAME_LENGTH = 100

  attr_accessible :name, :start_time, :end_time, :adult_ticket_price,
    :kid_ticket_price, :cabin_price, :max_adult_tickets_per_request,
    :max_kid_tickets_per_request, :max_cabins_per_request

  normalize_attributes :name

  validates :name, presence: true, length: { maximum: MAX_NAME_LENGTH }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :adult_ticket_price, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :kid_ticket_price, allow_nil: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :cabin_price, allow_nil: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :max_adult_tickets_per_request, allow_nil: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :max_kid_tickets_per_request, allow_nil: true,
    numericality: { only_integer: true, greater_than: 0 }
  validates :max_cabins_per_request, allow_nil: true,
    numericality: { only_integer: true, greater_than: 0 }

  validate :end_time_after_start_time, :ensure_prices_set_if_maximum_specified

private

  def end_time_after_start_time
    if start_time && end_time && end_time <= start_time
      errors.add(:end_time, 'must be after start time')
    end
  end

  def ensure_prices_set_if_maximum_specified
    if self.max_kid_tickets_per_request && self.kid_ticket_price.blank?
      errors.add(:max_kid_tickets_per_request, 'can be set only if a kid ticket price is set')
    end

    if self.max_cabins_per_request && self.cabin_price.blank?
      errors.add(:max_cabins_per_request, 'can be set only if a cabin price is set')
    end
  end
end
