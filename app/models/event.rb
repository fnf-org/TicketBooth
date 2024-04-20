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

  attr_accessible :name, :start_time, :end_time, :adult_ticket_price,
                  :early_arrival_price, :late_departure_price,
                  :kid_ticket_price, :cabin_price, :max_adult_tickets_per_request,
                  :max_kid_tickets_per_request, :max_cabins_per_request, :max_cabin_requests,
                  :photo, :photo_cache, :tickets_require_approval, :require_mailing_address,
                  :allow_financial_assistance, :allow_donations,
                  :ticket_sales_start_time, :ticket_sales_end_time, :ticket_requests_end_time

  mount_uploader :photo, PhotoUploader

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
  validates :max_cabin_requests, allow_nil: true,
                                 numericality: { only_integer: true, greater_than: 0 }

  validate :end_time_after_start_time, :sales_end_time_after_start_time,
           :ensure_prices_set_if_maximum_specified

  DEFAULT_ATTRIBUTES = {
    adult_ticket_price: 150,
    early_arrival_price: 20,
    kid_ticket_price: 50,
    late_departure_price: 20,
    max_adult_tickets_per_request: 4,
    max_kid_tickets_per_request: 2,
    max_cabins_per_request: 1,
    max_cabin_requests: 2,
    tickets_require_approval: true,
    require_mailing_address: false,
    allow_financial_assistance: true,
    allow_donations: true
  }.freeze

  def admin?(user)
    user && (user.site_admin? || admins.exists?(id: user))
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
    return false if ticket_sales_start_time && Time.zone.now < ticket_sales_start_time
    return Time.zone.now < ticket_sales_end_time if ticket_sales_end_time
    return false if Time.zone.now >= end_time

    true
  end

  def ticket_requests_open?
    return false if Time.zone.now >= end_time
    return true unless ticket_requests_end_time

    ticket_requests_end_time > Time.zone.now
  end

  def eald?
    early_arrival_price.positive? || late_departure_price.positive?
  end

  private

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
