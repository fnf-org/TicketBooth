require 'spec_helper'

describe SiteAdmin do
  it 'has a valid factory' do
    SiteAdmin.make.should be_valid
  end

  describe 'validations' do
    describe '#user' do
      it { should accept_values_for(:user_id, User.make!.id) }
      it { should_not accept_values_for(:user_id, nil) }

      context 'when the user is already a site admin' do
        let(:user) { User.make! :site_admin }

        it { should_not accept_values_for(:user_id, user.id) }
      end
    end
  end
end
