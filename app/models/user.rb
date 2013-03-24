class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  before_validation :strip_whitespace, :normalize_spaces

  validates_presence_of :name, :email

  validates_length_of :name, in: 2..70,
    too_short: 'is too short. Did you forget to enter it?',
    too_long: 'is too long. Perhaps remove middle names?'

  validates_format_of :name, with: /[^\s]+\s[^\s]+(\s[^\s]+)*/i,
    message: 'must include at least first and last name'

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def first_name
    name.split(' ').first
  end

  def site_admin?
    SiteAdmin.where(user_id: self).first.present?
  end

private

  def strip_whitespace
    self.name.strip
    self.email.strip
  end

  def normalize_spaces
    self.name.gsub!(/\s+/, ' ')
  end
end
