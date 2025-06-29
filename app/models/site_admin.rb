# frozen_string_literal: true

# == Schema Information
#
# Table name: site_admins
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SiteAdmin < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: { message: 'already site admin' }
end
