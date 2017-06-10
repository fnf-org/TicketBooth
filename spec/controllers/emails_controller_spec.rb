require 'spec_helper'

describe EmailsController, type: :controller do
  describe 'GET #index' do
    let(:email) { nil }

    before { get :index, email: email }

    context 'when no email is provided' do
      it { response.status.should eq 404 }
    end

    context 'when non-existent email is provided' do
      let(:email) { 'thisemailwillneverexist@nowaynohownowhere.com' }
      it { response.status.should eq 404 }
    end

    context 'when existing email is provided' do
      let(:email) { User.make!.email }
      it { response.status.should eq 200 }
    end
  end
end
