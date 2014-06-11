require 'securerandom'

# A real-life living breathing human.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :event_admins, dependent: :destroy
  has_many :events_administrated, through: :event_admins, source: :event
  has_many :ticket_requests
  has_one :site_admin, dependent: :destroy

  MAX_NAME_LENGTH = 70
  MAX_EMAIL_LENGTH = 254 # Based on RFC 3696; see http://isemail.info/about
  MAX_PASSWORD_LENGTH = 255

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :remember_me

  normalize_attributes :name, :email

  validates :name, presence: true,
    length: { maximum: MAX_NAME_LENGTH },
    format: { with: /[^\s]+\s[^\s]+(\s[^\s]+)*/i,
              message: 'must contain first and last name' }

  validates :email, presence: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
    length: { maximum: MAX_EMAIL_LENGTH }

  def first_name
    name.split(' ').first
  end

  def site_admin?
    !site_admin.nil?
  end

  def event_admin?
    event_admins.exists?
  end

  def generate_auth_token!
    token = SecureRandom.hex(32)
    update_attribute(:authentication_token, token)
    token
  end
end
