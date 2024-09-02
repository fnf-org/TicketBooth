# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  authentication_token   :string(64)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           not null
#  encrypted_password     :string           not null
#  failed_attempts        :integer          default(0)
#  first                  :text
#  last                   :text
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  name                   :string(70)       not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0)
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
require 'securerandom'

# A real-life living breathing human.
class User < ApplicationRecord
  # @see https://dev.to/kevinluo201/introduction-to-devise-modules-and-enable-all-of-them-4p25
  DEVISE_MODULES = %i[
    confirmable
    database_authenticatable
    registerable
    lockable
    recoverable
    rememberable
    trackable
    validatable
  ].freeze

  devise(*DEVISE_MODULES)

  class << self
    define_method 'has_devise_module?' do |module_name|
      DEVISE_MODULES.include?(module_name)
    end
  end

  has_many :event_admins, dependent: :destroy
  has_many :events_administrated, through: :event_admins, source: :event
  has_many :ticket_requests
  has_one :site_admin, dependent: :destroy

  MAX_NAME_LENGTH     = 40
  MAX_EMAIL_LENGTH    = 80 # Based on RFC 3696; see http://isemail.info/about
  MAX_PASSWORD_LENGTH = 40

  before_validation :canonize_full_name!

  normalize_attributes :name, :email

  validates :first, presence: true
  validates :last, presence: true

  validates :name, presence: true,
                   length: { maximum: MAX_NAME_LENGTH },
                   format: { with:    /\A\S+\s\S+(\s\S+)*\z/i,
                             message: 'must contain first and last name' }

  validates :email, presence: true,
                    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
                    length: { maximum: MAX_EMAIL_LENGTH }

  def first_name
    first
  end

  def last_name
    last
  end

  def site_admin?
    site_admin.present?
  end

  def name_and_email
    "#{name} <#{email}>"
  end

  def event_admin?
    event_admins.present? && !event_admins.empty?
  end

  def manages_event?(event)
    events_administrated.include?(event)
  end

  def generate_auth_token!
    token = SecureRandom.hex(32)
    update_attribute(:authentication_token, token)
    token
  end

  private

  def canonize_full_name!
    if name && first.nil? && last.nil?
      self.first, self.last = *name.split(/\s+/).map(&:strip)
    elsif name.nil? && first.present?
      self.name = first if first
      self.name += " #{last}" if name && last
    end
  end
end
