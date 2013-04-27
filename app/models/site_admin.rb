class SiteAdmin < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user

  validates :user_id, existence: true,
    uniqueness: { message: 'already site admin' }
end
