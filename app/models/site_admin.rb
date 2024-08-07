# frozen_string_literal: true

# == Schema Information
#
# Table name: site_admins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
class SiteAdmin < ApplicationRecord
  belongs_to :user

  validates :user, uniqueness: { message: 'already site admin' }
end
