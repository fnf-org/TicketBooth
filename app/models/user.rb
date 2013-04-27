class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :site_admin, dependent: :destroy

  MAX_NAME_LENGTH = 70
  MAX_EMAIL_LENGTH = 254 # Based on RFC 3696; see http://isemail.info/about
  MAX_PASSWORD_LENGTH = 255

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  normalize_attributes :name, :email

  validates :name, presence: true,
    length: { maximum: MAX_NAME_LENGTH },
    format: { with: /[^\s]+\s[^\s]+(\s[^\s]+)*/i }

  validates :email, presence: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i },
    length: { maximum: MAX_EMAIL_LENGTH }

  def first_name
    name.split(' ').first
  end

  def site_admin?
    !!site_admin
  end
end
