# frozen_string_literal: true

RSpec.describe PaymentsHelper do

  shared_examples_for 'payments helper' do |enabled: true, total: 0, expected_extra: 0|
    let(:amount) { total } # $10.00
    let(:expected_extra) { expected_extra } # $10.00

    before do
      described_class.extra_fees_enabled = enabled
      if subject.respond_to?(:amount)
        subject.extra_amount_to_charge(nil)
      else
        subject.extra_amount_to_charge(total)
      end
    end

    its(:extra_charge_amount) { is_expected.to eql(expected_extra) }
  end

  describe 'without the total field' do
    subject { (Class.new { include PaymentsHelper }).new }

    it_behaves_like 'payments helper', enabled: true, total: 1000, expected_extra: 31
    it_behaves_like 'payments helper', enabled: false, total: 1000, expected_extra: 0
  end

  describe 'without total field' do
    subject { (Class.new(Struct.new(:amount)) { include PaymentsHelper }).new(amount) }

    describe 'when total is $10' do
      let(:amount) { 1000 }

      it_behaves_like 'payments helper', enabled: true, total: 1000, expected_extra: 31
      it_behaves_like 'payments helper', enabled: false, total: 1000, expected_extra: 0
    end

    describe 'when total is $500' do
      let(:amount) { 50_000 }

      it_behaves_like 'payments helper', enabled: true, total: 50_000, expected_extra: 1494
      it_behaves_like 'payments helper', enabled: false, total: 50_000, expected_extra: 0
    end
  end
end
