# frozen_string_literal: true

require 'rails_helper'

describe TicketRequestsHelper, type: :helper do
  describe '#text_class_for_status' do
    {
      'P' => 'bg-warning',
      'A' => 'bg-warning-subtle',
      'D' => 'bg-danger-subtle',
      'R' => 'bg-danger-subtle',
      'C' => 'bg-success-subtle'
    }.each do |status, css_class|
      it "returns '#{css_class}' for status '#{status}'" do
        tr = instance_double(TicketRequest, status:)
        expect(helper.text_class_for_status(tr)).to eq css_class
      end
    end
  end

  describe '#text_for_status' do
    {
      'P' => 'Pending Approval',
      'A' => 'Awaiting Payment',
      'D' => 'Declined',
      'R' => 'Refunded',
      'C' => 'Completed'
    }.each do |status, label|
      it "returns '#{label}' for status '#{status}'" do
        tr = instance_double(TicketRequest, status:)
        expect(helper.text_for_status(tr)).to eq label
      end
    end

    it 'returns unknown message for unexpected status' do
      tr = instance_double(TicketRequest, status: 'X')
      expect(helper.text_for_status(tr)).to include('Unknown')
    end
  end

  describe '#help_text_for' do
    %i[email early_arrival late_departure kids address needs_assistance notes community_fund_donation].each do |sym|
      it "returns help text for :#{sym}" do
        result = helper.help_text_for(sym)
        expect(result).to be_a(String)
        expect(result.strip.length).to be > 5
      end
    end

    it 'returns nil for unknown symbol' do
      expect(helper.help_text_for(:unknown)).to be_nil
    end
  end
end
