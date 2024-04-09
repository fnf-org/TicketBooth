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
describe User do
  it 'has a valid factory' do
    described_class.make.should be_valid
  end

  describe 'validation' do
    describe '#name' do
      subject { user }

      let(:user) { described_class.make name: }

      context 'when not present' do
        let(:name) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when empty' do
        let(:name) { '' }

        it { is_expected.not_to be_valid }
      end

      context 'when longer than 70 characters' do
        let(:name) { "#{Sham.string(35)} #{Sham.string(35)}" }

        it { is_expected.not_to be_valid }
      end

      context 'when just a first name' do
        let(:name) { 'John' }

        it { is_expected.not_to be_valid }
      end

      context 'when both first and last name' do
        let(:name) { 'John Smith' }

        it { is_expected.to be_valid }
      end

      context 'when first, middle and last name' do
        let(:name) { 'John Jacob Smith' }

        it { is_expected.to be_valid }
      end

      context 'when multiples spaces are between names' do
        let(:name) { 'John     Smith' }

        it 'condenses multiple spaces into a single space' do
          user.valid?
          user.name.should == 'John Smith'
        end

        it { is_expected.to be_valid }
      end

      context 'when leading or trailing whitespace exists' do
        let(:name) { '  John Smith ' }

        it 'removes the surrounding whitespace' do
          user.valid?
          user.name.should == 'John Smith'
        end

        it { is_expected.to be_valid }
      end
    end

    describe '#email' do
      subject { user }

      let(:user) { described_class.make email: }

      context 'when not present' do
        let(:email) { nil }

        it { is_expected.not_to be_valid }
      end

      context 'when empty' do
        let(:email) { '' }

        it { is_expected.not_to be_valid }
      end

      context 'when email longer than 254 characters' do
        let(:email) { "#{Sham.string(243)}@example.com" }

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
    let(:first_name) { 'John' }
    let(:last_name) { 'Smith' }
    let(:user) { described_class.make name: [first_name, last_name].join(' ') }

    it 'returns the first name' do
      user.first_name.should == first_name
    end
  end

  describe '#site_admin?' do
    context 'when user is a site admin' do
      let(:user) { described_class.make! :site_admin }

      it 'returns true' do
        user.should be_site_admin
      end
    end

    context 'when user is not a site admin' do
      let(:user) { described_class.make! }

      it 'returns false' do
        user.should_not be_site_admin
      end
    end
  end

  describe '#destroy' do
    before do
      user.destroy
    end

    context 'when user is a site admin' do
      let(:user) { described_class.make! :site_admin }
      let(:site_admin) { user.site_admin }

      it 'destroys the associated site admin' do
        site_admin.should be_destroyed
      end
    end
  end
end
