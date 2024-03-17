# frozen_string_literal: true

# == Schema Information
#
# Table name: site_admins
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null

require 'rails_helper'

describe SiteAdmin do
  describe 'validations' do
    describe '#user' do
      it { is_expected.to accept_values_for(:user_id, User.make!.id) }
      it { is_expected.not_to accept_values_for(:user_id, nil) }

      context 'when the user is already a site admin' do
        let(:user) { User.make! :site_admin }

        it { is_expected.not_to accept_values_for(:user_id, user.id) }
      end
    end
  end
end
