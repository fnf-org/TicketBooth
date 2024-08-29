# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  authentication_token   :string(64)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           not null
#  encrypted_password     :string           not null
#  failed_attempts        :integer          default(0)
#  first                  :text
#  last                   :text
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  name                   :string(70)       not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0)
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#

require 'rails_helper'

describe User do
  let(:last) { nil }
  let(:first) { nil }

  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end

  describe 'login' do
    let(:user) { build(:user) }


    describe 'failed_attempts' do
      it 'has no failed attempts' do
        expect(user.failed_attempts).to eq(0)
      end
    end
  end

  describe 'validation' do
    describe '#first and #last' do
      subject(:user) { build(:user, first:, last:) }

      context 'when not present' do
        it { is_expected.not_to be_valid }
      end

      context 'when empty' do
        let(:first) { '' }
        let(:last) { '' }

        it { is_expected.not_to be_valid }
      end

      context 'when only first name exists' do
        let(:first) { Faker::Name.first_name }

        it { is_expected.not_to be_valid }
      end

      context 'when only the last name exists' do
        let(:last) { 'Smith' }

        it { is_expected.not_to be_valid }
      end

      context 'when first, middle and last name' do
        let(:first) { 'John Jacob' }
        let(:last) { 'Smith' }

        it { is_expected.to be_valid }
      end

      context 'when multiples spaces are between names' do
        let(:first) { 'John     Jacob' }
        let(:last) { 'Smith' }

        it 'condenses multiple spaces into a single space' do
          user.valid?
          user.name.should == 'John Jacob Smith'
        end

        it { is_expected.to be_valid }
      end

      context 'when leading or trailing whitespace exists' do
        let(:first) { '  John    Jacob   ' }
        let(:last) { 'Smith' }

        it 'removes the surrounding whitespace' do
          user.valid?
          user.name.should == 'John Jacob Smith'
        end

        it { is_expected.to be_valid }
      end
    end

    describe '#email' do
      subject(:user) { build(:user, email:) }

      context 'when not present' do
        let(:email) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when empty' do
        let(:email) { '' }

        it { is_expected.not_to be_valid }
      end

      context 'when email longer than 254 characters' do
        let(:email) { "#{Faker::Alphanumeric.alpha(number: 254)}@example.com" }

        it { is_expected.not_to be_valid }
      end

      context 'when not in a valid format' do
        let(:email) { 'a_fake_email' }

        it { is_expected.not_to be_valid }
      end

      context 'when in a valid format' do
        let(:email) { 'email@example.com' }

        it { is_expected.to be_valid }
      end
    end
  end

  describe '#first_name' do
    let(:first) { 'John' }
    let(:last) { 'Smith' }
    let(:user) { create(:user, first:, last:) }

    it 'returns the first name' do
      user.name.should == "#{first} #{last}"
    end
  end

  describe '#site_admin?' do
    context 'when user is a site admin' do
      let(:user) { create(:site_admin).user }

      it 'returns true' do
        expect(user).to be_site_admin
      end
    end

    context 'when user is not a site admin' do
      let(:user) { create(:user) }

      it 'returns false' do
        expect(user).not_to be_site_admin
      end
    end
  end

  describe '#destroy' do
    before do
      user.destroy
    end

    context 'when user is a site admin' do
      let(:site_admin) { create(:site_admin) }
      let(:user) { site_admin.user }

      it 'destroys the associated site admin' do
        expect(site_admin).to be_destroyed
      end
    end
  end
end
