# frozen_string_literal: true

require 'rails_helper'

describe Event, type: :model do
  describe 'secret_token' do
    subject(:event) { create(:event, name: 'Test Event') }

    it 'is auto-generated on create' do
      expect(event.secret_token).to be_present
    end

    its(:secret_token) { is_expected.to match(/\A[a-z0-9]{8}\z/) }

    it 'is unique across events' do
      tokens = 5.times.map { create(:event).secret_token }
      expect(tokens.uniq.length).to eq 5
    end

    it 'is not overwritten if already set' do
      event = build(:event, secret_token: 'abcd1234')
      event.save!
      expect(event.secret_token).to eq 'abcd1234'
    end

    it 'is nullable for legacy events' do
      event.update_column(:secret_token, nil)
      expect(event.reload.secret_token).to be_nil
    end
  end

  describe '#to_param' do
    subject(:event) { create(:event, name: 'Summer Campout') }

    context 'with secret_token' do
      it 'returns token-slug format' do
        expect(event.to_param).to eq "#{event.secret_token}-summer-campout"
      end

      it 'does not include the numeric ID' do
        expect(event.to_param).not_to start_with("#{event.id}-")
      end
    end

    context 'without secret_token (legacy)' do
      before { event.update_column(:secret_token, nil) }

      it 'returns id-slug format' do
        expect(event.reload.to_param).to eq "#{event.id}-summer-campout"
      end
    end

    context 'when not persisted' do
      subject(:event) { build(:event) }

      its(:to_param) { is_expected.to be_nil }
    end
  end
end
