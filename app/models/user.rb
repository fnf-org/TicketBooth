class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  validates_presence_of :name, :email

  validates_length_of :name, in: 2..70,
    too_short: 'is too short. Did you forget to enter it?',
    too_long: 'is too long. Perhaps remove middle names?'

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  def first_name
    name.split(' ').first
  end

  def site_admin?
    SiteAdmin.where(user_id: self).first.present?
  end
end
