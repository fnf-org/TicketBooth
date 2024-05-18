# frozen_string_literal: true

# == Schema Information
#
# Table name: site_admins
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer          not null
#
class SiteAdmin < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: { message: 'already site admin' }
end
