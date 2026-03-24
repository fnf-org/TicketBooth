# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#alert_class' do
    subject { helper.alert_class(alert_type) }

    context 'when alert_type is notice' do
      let(:alert_type) { 'notice' }

      it { is_expected.to eq 'alert-info' }
    end

    context 'when alert_type is error' do
      let(:alert_type) { 'error' }

      it { is_expected.to eq 'alert-danger' }
    end

    context 'when alert_type is alert' do
      let(:alert_type) { 'alert' }

      it { is_expected.to eq 'alert-danger' }
    end

    context 'when alert_type is warning' do
      let(:alert_type) { 'warning' }

      it { is_expected.to eq 'alert-warning' }
    end

    context 'when alert_type is unknown' do
      let(:alert_type) { 'something_else' }

      it { is_expected.to eq 'alert-primary' }
    end
  end

  describe '#tooltip_box' do
    subject { helper.tooltip_box('Some content', title: 'My Title') }

    it { is_expected.to include('data-bs-toggle="popover"') }
    it { is_expected.to include('data-bs-content="Some content"') }
    it { is_expected.to include('tooltip-box') }
    it { is_expected.to include('bi-question-square') }

    context 'with a block' do
      subject { helper.tooltip_box('Content', title: 'Title') { 'Custom block' } }

      it { is_expected.to include('Custom block') }
      it { is_expected.not_to include('bi-question-square') }
    end

    context 'with a custom CSS class' do
      subject { helper.tooltip_box('Content', title: 'Title', class: 'extra-class') }

      it { is_expected.to include('extra-class') }
    end
  end

  describe '#devise_mapping' do
    subject { helper.devise_mapping }

    it { is_expected.to eq Devise.mappings[:user] }
  end

  describe '#resource_name' do
    subject { helper.resource_name }

    it { is_expected.to eq :user }
  end

  describe '#resource_class' do
    subject { helper.resource_class }

    it { is_expected.to eq User }
  end
end
