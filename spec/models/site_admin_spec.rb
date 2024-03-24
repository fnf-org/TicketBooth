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
    describe '#site_admin' do
      subject(:site_admin) { create(:site_admin) }

      let(:user) { site_admin.user }

      describe 'when the user is not a site admin' do
        it { is_expected.to accept_values_for(:user, user) }
        it { is_expected.not_to accept_values_for(:user, nil) }
      end

      context 'when the user is already a site admin' do
        let(:site_admin2) { create(:site_admin, user:) }

        it 'is not able to save' do
          expect { site_admin2 }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
