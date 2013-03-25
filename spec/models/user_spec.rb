require 'spec_helper'

describe User do
  it 'has a valid factory' do
    User.make.should be_valid
  end

  describe 'validation' do
    describe '#name' do
      let(:user) { User.make name: name }
      subject { user }

      context 'when not present' do
        let(:name) { nil }
        it { should_not be_valid }
      end

      context 'when empty' do
        let(:name) { '' }
        it { should_not be_valid }
      end

      context 'when longer than 70 characters' do
        let(:name) { Sham.string(35) + ' ' + Sham.string(35) }
        it { should_not be_valid }
      end

      context 'when just a first name' do
        let(:name) { 'John' }
        it { should_not be_valid }
      end

      context 'when both first and last name' do
        let(:name) { 'John Smith' }
        it { should be_valid }
      end

      context 'when first, middle and last name' do
        let(:name) { 'John Jacob Smith' }
        it { should be_valid }
      end

      context 'when multiples spaces are between names' do
        let(:name) { 'John     Smith' }

        it 'condenses multiple spaces into a single space' do
          user.valid?
          user.name.should == 'John Smith'
        end

        it { should be_valid }
      end

      context 'when leading or trailing whitespace exists' do
        let(:name) { '  John Smith ' }

        it 'removes the surrounding whitespace' do
          user.valid?
          user.name.should == 'John Smith'
        end

        it { should be_valid }
      end
    end

    describe '#email' do
      let(:user) { User.make email: email }
      subject { user }

      context 'when not present' do
        let(:email) { nil }
        it { should_not be_valid }
      end

      context 'when empty' do
        let(:email) { '' }
        it { should_not be_valid }
      end

      context 'when email longer than 254 characters' do
        let(:email) { Sham.string(243) + '@example.com' }
        it { should_not be_valid }
      end

      context 'when not in a valid format' do
        let(:email) { 'a_fake_email' }
        it { should_not be_valid }
      end

      context 'when in a valid format' do
        let(:email) { 'email@example.com' }
        it { should be_valid }
      end
    end
  end

  describe '#first_name' do
    let(:first_name) { 'John' }
    let(:last_name) { 'Smith' }
    let(:user) { User.make name: [first_name, last_name].join(' ') }

    it 'returns the first name' do
      user.first_name.should == first_name
    end
  end

  describe '#site_admin?' do
    context 'when user is a site admin' do
      let(:user) { User.make! :site_admin }

      it 'returns true' do
        user.should be_site_admin
      end
    end

    context 'when user is not a site admin' do
      let(:user) { User.make! }

      it 'returns false' do
        user.should_not be_site_admin
      end
    end
  end
end
