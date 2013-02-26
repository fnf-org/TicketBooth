class SiteAdmin < ActiveRecord::Base
  attr_accessible :user_id

  validates_presence_of :user_id

  belongs_to :user
end
