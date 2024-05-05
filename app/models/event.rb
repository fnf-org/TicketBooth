# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                            :bigint           not null, primary key
#  adult_ticket_price            :decimal(8, 2)
#  allow_donations               :boolean          default(FALSE), not null
#  allow_financial_assistance    :boolean          default(FALSE), not null
#  cabin_price                   :decimal(8, 2)
#  early_arrival_price           :decimal(8, 2)    default(0.0)
#  end_time                      :datetime
#  kid_ticket_price              :decimal(8, 2)
#  late_departure_price          :decimal(8, 2)    default(0.0)
#  max_adult_tickets_per_request :integer
#  max_cabin_requests            :integer
#  max_cabins_per_request        :integer
#  max_kid_tickets_per_request   :integer
#  name                          :string
#  photo                         :string
#  require_mailing_address       :boolean          default(FALSE), not null
#  slug                          :text
#  start_time                    :datetime
#  ticket_requests_end_time      :datetime
#  ticket_sales_end_time         :datetime
#  ticket_sales_start_time       :datetime
#  tickets_require_approval      :boolean          default(TRUE), not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class Event < ApplicationRecord
  has_many :event_admins
  has_many :admins, through: :event_admins, source: :user
  has_many :jobs, dependent: :destroy
  has_many :time_slots, through: :jobs
  has_many :ticket_requests, dependent: :destroy
  has_many :price_rules, dependent: :destroy

  MAX_NAME_LENGTH = 100

  GUEST_LIST_FINAL_WITHIN = 2.days

  attr_accessible :name, :start_time, :end_time, :adult_ticket_price,
                  :early_arrival_price, :late_departure_price,
                  :kid_ticket_price, :cabin_price, :max_adult_tickets_per_request,
                  :max_kid_tickets_per_request, :max_cabins_per_request, :max_cabin_requests,
                  :photo, :photo_cache, :tickets_require_approval, :require_mailing_address,
                  :allow_financial_assistance, :allow_donations,
                  :ticket_sales_start_time, :ticket_sales_end_time,
                  :ticket_requests_end_time

  mount_uploader :photo, PhotoUploader

  normalize_attributes :name

  before_validation :generate_slug!

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
  validates :max_cabin_requests, allow_nil: true,
                                 numericality: { only_integer: true, greater_than: 0 }

  validate :end_time_after_start_time, :sales_end_time_after_start_time,
           :ensure_prices_set_if_maximum_specified

  START_DATE_WITH_OFFSET = ->(delta = 0) { Date.current + 2.months + delta }
  DEFAULT_ATTRIBUTES     = {
    start_time:                    START_DATE_WITH_OFFSET[11.hours],
    end_time:                      START_DATE_WITH_OFFSET[3.days + 14.hours],
    ticket_requests_end_time:      START_DATE_WITH_OFFSET[-14.days],
    ticket_sales_start_time:       START_DATE_WITH_OFFSET[-42.days],
    ticket_sales_end_time:         START_DATE_WITH_OFFSET[7.days],

    adult_ticket_price:            250,
    early_arrival_price:           0,
    kid_ticket_price:              0,
    late_departure_price:          30,

    max_adult_tickets_per_request: 10,
    max_kid_tickets_per_request:   4,

    tickets_require_approval:      true,
    allow_financial_assistance:    true,
    allow_donations:               true,

    require_mailing_address:       false,

    max_cabins_per_request:        nil,
    max_cabin_requests:            nil,
    cabin_price:                   nil
  }.freeze

  def long_name
    "#{name} (Starting #{starting})"
  end

  def starting
    TimeHelper.for_display(start_time)
  end

  def admin?(user)
    user && (user.site_admin? || admins.exists?(id: user))
  end

  def admin_contacts
    admins.map(&:name_and_email)
  end

  def make_admin(user)
    return false if admin?(user)

    EventAdmin.create(user_id: user.id, event_id: id)
  end

  def cabins_available?
    return false unless cabin_price
    return true unless max_cabin_requests

    ticket_requests.not_declined.sum(:cabins) < max_cabin_requests
  end

  def ticket_sales_open?
    if ticket_sales_start_time && Time.current.before?(ticket_sales_start_time)
      errors.add(:ticket_sales_start_time, 'Tickets are not yet on sale for this event.')
    elsif ticket_sales_end_time && Time.current.after?(ticket_sales_end_time)
      errors.add(:ticket_sales_end_time, 'Tickets are no longer on sale for this event.')
    elsif Time.current.after?(end_time)
      errors.add(:end_time, 'This event has ended, so no ticket sales sare accepted anymore.')
    else
      return true
    end
    Rails.logger.error("ticket_sales_open? -> false, reason: #{errors.full_messages.join('; ')}".colorize(:red))
    false
  end

  def ticket_requests_open?
    if ticket_requests_end_time && Time.current.after?(ticket_requests_end_time)
      errors.add(:ticket_requests_end_time, 'Ticket requests are no longer accepted.')
    elsif Time.current.after?(end_time)
      errors.add(:end_time, 'This event has ended, so no ticket requests are accepted anymore.')
    else
      return true
    end
    Rails.logger.error("ticket_requests_open? -> false, reason: #{errors.full_messages.join('; ')}".colorize(:red))
    false
  end

  def eald?
    early_arrival_price.positive? || late_departure_price.positive?
  end

  def to_param
    return nil unless persisted?

    [id, slug].join('--') # 1--summer-campout-xii
  end

  private

  def generate_slug!
    self.slug = name&.parameterize
  end

  def end_time_after_start_time
    errors.add(:end_time, 'must be after start time') if start_time && end_time && end_time <= start_time
  end

  def sales_end_time_after_start_time
    if ticket_sales_start_time && ticket_sales_end_time &&
       ticket_sales_end_time <= ticket_sales_start_time
      errors.add(:ticket_sales_end_time, 'must be after start time')
    end
  end

  def ensure_prices_set_if_maximum_specified
    if max_kid_tickets_per_request && kid_ticket_price.blank?
      errors.add(:max_kid_tickets_per_request,
                 'can be set only if a kid ticket price is set')
    end

    if max_cabins_per_request && cabin_price.blank?
      errors.add(:max_cabins_per_request,
                 'can be set only if a cabin price is set')
    end

    if max_cabin_requests && cabin_price.blank?
      errors.add(:max_cabin_requests,
                 'can be set only if a cabin price is set')
    end
  end
end
