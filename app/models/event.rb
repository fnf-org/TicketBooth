# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id                            :bigint           not null, primary key
#  adult_ticket_price            :integer
#  allow_donations               :boolean          default(FALSE), not null
#  allow_financial_assistance    :boolean          default(FALSE), not null
#  end_time                      :datetime
#  kid_ticket_price              :integer
#  max_adult_tickets_per_request :integer
#  max_kid_tickets_per_request   :integer
#  name                          :string
#  photo                         :string
#  require_mailing_address       :boolean          default(FALSE), not null
#  require_role                  :boolean          default(TRUE), not null
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
  has_many :event_addons, dependent: :destroy
  has_many :addons, through: :event_addons

  MAX_NAME_LENGTH = 100

  GUEST_LIST_FINAL_WITHIN = 2.days

  attr_accessible :name, :start_time, :end_time, :adult_ticket_price,
                  :kid_ticket_price, :max_adult_tickets_per_request, :max_kid_tickets_per_request,
                  :photo, :photo_cache, :tickets_require_approval, :require_mailing_address,
                  :require_role, :allow_financial_assistance, :allow_donations,
                  :ticket_sales_start_time, :ticket_sales_end_time,
                  :ticket_requests_end_time, :event_addons_attributes

  accepts_nested_attributes_for :event_addons

  mount_uploader :photo, PhotoUploader

  normalize_attributes :name

  before_validation :generate_slug!
  before_validation :ensure_require_role_set_default

  validates :name, presence: true, length: { maximum: MAX_NAME_LENGTH }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :adult_ticket_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :kid_ticket_price, allow_nil: true, numericality: { greater_than_or_equal_to: 0 }
  validates :max_adult_tickets_per_request, allow_nil: true, numericality: { only_integer: true, greater_than: 0 }
  validates :max_kid_tickets_per_request, allow_nil: true, numericality: { only_integer: true, greater_than: 0 }

  validate :end_time_after_start_time, :sales_end_time_after_start_time

  scope :sales_open, -> { where('ticket_sales_start_time < :now', now: Time.current) }
  scope :future_event, -> { where('start_time > :now', now: Time.current) }
  scope :live_events, -> { sales_open.future_event.order('start_time ASC') }

  START_DATE_WITH_OFFSET = ->(delta = 0) { Date.current + 2.months + delta }
  DEFAULT_ATTRIBUTES     = {
    start_time:                    START_DATE_WITH_OFFSET[11.hours],
    end_time:                      START_DATE_WITH_OFFSET[3.days + 14.hours],
    ticket_requests_end_time:      START_DATE_WITH_OFFSET[-14.days],
    ticket_sales_start_time:       START_DATE_WITH_OFFSET[-42.days],
    ticket_sales_end_time:         START_DATE_WITH_OFFSET[7.days],

    adult_ticket_price:            220,
    kid_ticket_price:              100,

    max_adult_tickets_per_request: 6,
    max_kid_tickets_per_request:   4,

    tickets_require_approval:      true,
    allow_financial_assistance:    true,
    allow_donations:               true,

    require_mailing_address:       false,
    require_role:                  true
  }.freeze

  def admissible_requests
    ticket_requests
      .for_guest_list
      .order('status desc')
  end

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

  StatusWidget = Struct.new(:name, :css_class)

  def status
    if past_event?
      StatusWidget.new('Past Event', 'secondary')
    elsif ticket_sales_open?
      StatusWidget.new('On Sale', 'success')
    elsif ticket_requests_open?
      StatusWidget.new('Collecting Requests', 'primary')
    elsif future_event?
      StatusWidget.new('A Future Event', 'warning')
    else
      StatusWidget.new('Unknown', 'danger')
    end
  end

  def revenue
    ticket_requests.completed.map(&:payment)
  end

  def past_event?
    Time.current.after?(end_time)
  end

  def future_event?
    Time.current.before?(start_time)
  end

  def ticket_sales_open?
    if ticket_sales_start_time && Time.current.before?(ticket_sales_start_time)
      errors.add(:ticket_sales_start_time, 'Tickets are not yet on sale for this event.')
    elsif ticket_sales_end_time && Time.current.after?(ticket_sales_end_time)
      errors.add(:ticket_sales_end_time, 'Tickets are no longer on sale for this event.')
    elsif past_event?
      errors.add(:end_time, 'This event has ended and ticket sales are closed.')
    else
      return true
    end
    Rails.logger.error("ticket_sales_open? -> false, reason: #{errors.full_messages.join('; ')}".colorize(:red))
    false
  end

  def ticket_requests_open?
    if ticket_requests_end_time.present? && Time.current.after?(ticket_requests_end_time)
      errors.add(:ticket_requests_end_time, 'Ticket requests are no longer accepted.')
    elsif Time.current.after?(end_time)
      errors.add(:end_time, 'This event has ended and ticket sales are closed.')
    elsif ticket_sales_start_time.present? && Time.current.before?(ticket_sales_start_time)
      errors.add(:end_time, 'Tickets are not on sale yet for this event')
    else
      return true
    end
    Rails.logger.error("ticket_requests_open? -> false, reason: #{errors.full_messages.join('; ')}".colorize(:red))
    false
  end

  def to_param
    return nil unless persisted?

    [id, slug].join('-') # 1-summer-campout-xii
  end

  def build_event_addons_from_params(build_params)
    return if build_params.blank?

    Rails.logger.debug { "build_event_addons_from_params: #{build_params}" }

    build_params.each_value do |value|
      if Addon.exists?(id: value['addon_id'])
        event_addons.build({ event_id: id, addon_id: value['addon_id'], price: value['price'] })
      end
    end

    Rails.logger.debug { "build_event_addons_from_params: save: #{event_addons.inspect}" }
    event_addons
  end

  # create default event addons from Addons
  def create_default_event_addons
    return if event_addons.present?

    build_default_event_addons
    save
    Rails.logger.debug { "create_default_event_addons: save: #{event_addons.inspect}" }
    event_addons
  end

  def build_default_event_addons
    return if event_addons.present?

    Addon.order_by_category.each do |addon|
      event_addons.build({ event: self, addon: }).set_default_values
    end

    Rails.logger.debug { "build_default_event_addons: #{event_addons.inspect}" }
    event_addons
  end

  def active_event_addons
    event_addons.where('price > ?', 0)
  end

  def active_event_addons?
    event_addons.where('price > ?', 0).count.positive?
  end

  def active_event_addons_passes_count
    active_event_addons_by_category(Addon::CATEGORY_PASS).count
  end

  def active_event_addons_camping_count
    active_event_addons_by_category(Addon::CATEGORY_CAMP).count
  end

  def active_event_addons_by_category(category)
    event_addons.joins(:addon, :event)
                .where(event_id: id, 'addon.category' => category)
                .where('price > ?', 0)
  end

  def active_sorted_event_addons
    event_addons.where('price > ?', 0).sort_by { |e| [e.category, e.price, e.name] }
  end

  def sorted_event_addons
    event_addons.sort_by { |e| [e.category, e.id] }
  end

  def passes?
    active_sorted_event_addons
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

  def ensure_require_role_set_default
    attributes[:require_role] = true if attributes[:require_role].nil?
  end
end
